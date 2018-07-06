unit BMPConverFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.StdCtrls, FMX.Layouts, FMX.TabControl, FMX.Controls.Presentation,
  FMX.Objects, FMX.Colors, FMX.Ani, FMX.ListBox,
  FMX.Surfaces, FMX.ExtCtrls,

  MemoryRaster, Geometry2DUnit, CoreClasses, UnicodeMixedLib, PascalStrings, zDrawEngine;

type
  TBMPConverForm = class(TForm)
    converbmpButton: TButton;
    StyleBook1: TStyleBook;
    Layout1: TLayout;
    DestDirEdit: TEdit;
    Label1: TLabel;
    seldirEditButton: TEditButton;
    SameDirCheckBox: TCheckBox;
    AddFileButton: TButton;
    ClearButton: TButton;
    OpenDialog: TOpenDialog;
    ListBox: TListBox;
    converseqButton: TButton;
    converjlsButton: TButton;
    RadioButton_JLS8: TRadioButton;
    RadioButton_JLS24: TRadioButton;
    RadioButton_JLS32: TRadioButton;
    Image: TImageViewer;
    procedure AddFileButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ListBoxChange(Sender: TObject);
    procedure converbmpButtonClick(Sender: TObject);
    procedure seldirEditButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure converseqButtonClick(Sender: TObject);
    procedure converjlsButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BMPConverForm: TBMPConverForm;

implementation

{$R *.fmx}


procedure MemoryBitmapToSurface(bmp: TMemoryRaster; Surface: TBitmapSurface); overload;
var
  i: Integer;
  p1, p2: PCardinal;
  C: TRasterColorEntry;
  DC: TAlphaColor;
begin
{$IF Defined(ANDROID) or Defined(IOS)}
  Surface.SetSize(bmp.width, bmp.height, TPixelFormat.RGBA);
{$ELSE}
  Surface.SetSize(bmp.width, bmp.height, TPixelFormat.BGRA);
{$ENDIF}
  p1 := PCardinal(@bmp.Bits[0]);
  p2 := PCardinal(Surface.Bits);
  for i := bmp.width * bmp.height - 1 downto 0 do
    begin
{$IF Defined(ANDROID) or Defined(IOS) or Defined(OSX)}
      C.RGBA := RGBA2BGRA(TRasterColor(p1^));
{$ELSE}
      C.RGBA := TRasterColor(p1^);
{$IFEND}
      TAlphaColorRec(DC).R := C.R;
      TAlphaColorRec(DC).g := C.g;
      TAlphaColorRec(DC).b := C.b;
      TAlphaColorRec(DC).A := C.A;
      p2^ := DC;
      Inc(p1);
      Inc(p2);
    end;
end;

procedure MemoryBitmapToSurface(bmp: TMemoryRaster; sourRect: TRect; Surface: TBitmapSurface); overload;
var
  nb: TMemoryRaster;
begin
  nb := TMemoryRaster.Create;
  nb.DrawMode := dmBlend;
  nb.SetSize(sourRect.width, sourRect.height, RasterColor(0, 0, 0, 0));
  bmp.DrawTo(nb, 0, 0, sourRect);
  MemoryBitmapToSurface(nb, Surface);
  DisposeObject(nb);
end;

procedure SurfaceToMemoryBitmap(Surface: TBitmapSurface; bmp: TMemoryRaster); overload;
var
  X, Y: Integer;
begin
  bmp.SetSize(Surface.width, Surface.height);
  for Y := 0 to Surface.height - 1 do
    for X := 0 to Surface.width - 1 do
      with TAlphaColorRec(Surface.pixels[X, Y]) do
          bmp.Pixel[X, Y] := RasterColor(R, g, b, A)
end;

procedure MemoryBitmapToBitmap(b: TMemoryRaster; bmp: TBitmap); overload;
var
  Surface: TBitmapSurface;
begin
  Surface := TBitmapSurface.Create;
  MemoryBitmapToSurface(b, Surface);
  bmp.Assign(Surface);
  DisposeObject(Surface);
end;

procedure MemoryBitmapToBitmap(b: TMemoryRaster; sourRect: TRect; bmp: TBitmap); overload;
var
  Surface: TBitmapSurface;
begin
  Surface := TBitmapSurface.Create;
  MemoryBitmapToSurface(b, sourRect, Surface);
  bmp.Assign(Surface);
  DisposeObject(Surface);
end;

procedure BitmapToMemoryBitmap(bmp: TBitmap; b: TMemoryRaster); overload;
var
  Surface: TBitmapSurface;
begin
  Surface := TBitmapSurface.Create;
  Surface.Assign(bmp);
  SurfaceToMemoryBitmap(Surface, b);
  DisposeObject(Surface);
end;

procedure LoadMemoryBitmap(F: SystemString; b: TMemoryRaster); overload;
var
  Surf: TBitmapSurface;
begin
  if b.CanLoadFile(F) then
    begin
      b.LoadFromFile(F);
    end
  else
    begin
      Surf := TBitmapSurface.Create;
      try
        if TBitmapCodecManager.LoadFromFile(F, Surf, TCanvasManager.DefaultCanvas.GetAttribute(TCanvasAttribute.MaxBitmapSize)) then
            SurfaceToMemoryBitmap(Surf, b);
      finally
          DisposeObject(Surf);
      end;
    end;
end;

procedure LoadMemoryBitmap(stream: TCoreClassStream; b: TMemoryRaster); overload;
var
  Surf: TBitmapSurface;
begin
  if b.CanLoadStream(stream) then
    begin
      b.LoadFromStream(stream);
    end
  else
    begin
      Surf := TBitmapSurface.Create;
      try
        if TBitmapCodecManager.LoadFromStream(stream, Surf, TCanvasManager.DefaultCanvas.GetAttribute(TCanvasAttribute.MaxBitmapSize)) then
            SurfaceToMemoryBitmap(Surf, b);
      finally
          DisposeObject(Surf);
      end;
    end;
end;

procedure LoadMemoryBitmap(F: SystemString; b: TSequenceMemoryRaster); overload;
begin
  if b.CanLoadFile(F) then
      b.LoadFromFile(F)
  else
      LoadMemoryBitmap(F, TMemoryRaster(b));
end;

procedure LoadMemoryBitmap(F: SystemString; b: TDETexture); overload;
begin
  LoadMemoryBitmap(F, TSequenceMemoryRaster(b));
  b.ReleaseFMXResource;
end;

procedure SaveMemoryBitmap(F: SystemString; b: TMemoryRaster); overload;
var
  Surf: TBitmapSurface;
begin
  if umlMultipleMatch(['*.bmp'], F) then
      b.SaveToFile(F)
  else if umlMultipleMatch(['*.seq'], F) then
      b.SaveToZLibCompressFile(F)
  else
    begin
      Surf := TBitmapSurface.Create;
      try
        MemoryBitmapToSurface(b, Surf);
        TBitmapCodecManager.SaveToFile(F, Surf, nil);
      finally
          DisposeObject(Surf);
      end;
    end;
end;

procedure SaveMemoryBitmap(b: TMemoryRaster; fileExt: SystemString; DestStream: TCoreClassStream); overload;
var
  Surf: TBitmapSurface;
begin
  if umlMultipleMatch(['.bmp'], fileExt) then
      b.SaveToBmpStream(DestStream)
  else
    begin
      Surf := TBitmapSurface.Create;
      try
        MemoryBitmapToSurface(b, Surf);
        TBitmapCodecManager.SaveToStream(DestStream, Surf, fileExt);
      finally
          DisposeObject(Surf);
      end;
    end;
end;

procedure SaveMemoryBitmap(b: TSequenceMemoryRaster; fileExt: SystemString; DestStream: TCoreClassStream); overload;
var
  Surf: TBitmapSurface;
begin
  if umlMultipleMatch(['.bmp'], fileExt) then
      b.SaveToBmpStream(DestStream)
  else if umlMultipleMatch(['.seq'], fileExt) then
      b.SaveToStream(DestStream)
  else
    begin
      Surf := TBitmapSurface.Create;
      try
        MemoryBitmapToSurface(b, Surf);
        TBitmapCodecManager.SaveToStream(DestStream, Surf, fileExt);
      finally
          DisposeObject(Surf);
      end;
    end;
end;

procedure TBMPConverForm.AddFileButtonClick(Sender: TObject);
var
  i: Integer;
  itm: TListBoxItem;
begin
  OpenDialog.Filter := '*.*';
  if not OpenDialog.Execute then
      exit;
  ListBox.BeginUpdate;
  for i := 0 to OpenDialog.Files.Count - 1 do
    begin
      itm := TListBoxItem.Create(ListBox);
      itm.ItemData.Text := umlGetFileName(OpenDialog.Files[i]);
      itm.ItemData.Detail := umlGetFilePath(OpenDialog.Files[i]);
      itm.TagString := OpenDialog.Files[i];
      itm.StyleLookup := 'listboxitembottomdetail';
      itm.height := 40;
      itm.Selectable := True;
      ListBox.AddObject(itm);
    end;
  ListBox.EndUpdate;
end;

procedure TBMPConverForm.ClearButtonClick(Sender: TObject);
begin
  ListBox.Clear;
end;

procedure TBMPConverForm.converbmpButtonClick(Sender: TObject);
  function GetDestFile(sour: string): string;
  var
    F: string;
  begin
    if SameDirCheckBox.IsChecked then
        Result := umlChangeFileExt(sour, '.bmp')
    else
      begin
        F := umlGetFileName(sour);
        Result := umlChangeFileExt(umlCombineFileName(DestDirEdit.Text, F), '.bmp');
      end;
  end;

var
  i: Integer;
  itm: TListBoxItem;
  F: string;
  b: TMemoryRaster;
begin
  if ListBox.Count <= 0 then
      exit;

  for i := 0 to ListBox.Count - 1 do
    begin
      itm := ListBox.ListItems[i];
      F := itm.TagString;

      b := TMemoryRaster.Create;
      LoadMemoryBitmap(itm.TagString, b);
      b.SaveToFile(GetDestFile(F));
      Caption := Format('%s -> %s ok!', [umlGetFileName(itm.TagString).Text, umlGetFileName(GetDestFile(F)).Text]);
      DisposeObject(b);
    end;
  Caption := Format('all conver done!', []);
end;

procedure TBMPConverForm.converjlsButtonClick(Sender: TObject);
  function GetDestFile(sour: string): string;
  var
    F: string;
  begin
    if SameDirCheckBox.IsChecked then
        Result := umlChangeFileExt(sour, '.jls')
    else
      begin
        F := umlGetFileName(sour);
        Result := umlChangeFileExt(umlCombineFileName(DestDirEdit.Text, F), '.jls');
      end;
  end;

var
  i: Integer;
  itm: TListBoxItem;
  F: string;
  b: TSequenceMemoryRaster;
begin
  if ListBox.Count <= 0 then
      exit;

  for i := 0 to ListBox.Count - 1 do
    begin
      itm := ListBox.ListItems[i];
      F := itm.TagString;

      b := TSequenceMemoryRaster.Create;
      LoadMemoryBitmap(itm.TagString, b);

      if RadioButton_JLS8.IsChecked then
          b.SaveToJpegLS1File(GetDestFile(F))
      else if RadioButton_JLS24.IsChecked then
          b.SaveToJpegLS3File(GetDestFile(F))
      else
          b.SaveToJpegAlphaFile(GetDestFile(F));

      Caption := Format('%s -> %s ok!', [umlGetFileName(itm.TagString).Text, umlGetFileName(GetDestFile(F)).Text]);
      DisposeObject(b);
    end;
  Caption := Format('all conver done!', []);
end;

procedure TBMPConverForm.converseqButtonClick(Sender: TObject);
  function GetDestFile(sour: string): string;
  var
    F: string;
  begin
    if SameDirCheckBox.IsChecked then
        Result := umlChangeFileExt(sour, '.seq')
    else
      begin
        F := umlGetFileName(sour);
        Result := umlChangeFileExt(umlCombineFileName(DestDirEdit.Text, F), '.seq');
      end;
  end;

var
  i: Integer;
  itm: TListBoxItem;
  F: string;
  b: TSequenceMemoryRaster;
begin
  if ListBox.Count <= 0 then
      exit;

  for i := 0 to ListBox.Count - 1 do
    begin
      itm := ListBox.ListItems[i];
      F := itm.TagString;

      b := TSequenceMemoryRaster.Create;
      LoadMemoryBitmap(itm.TagString, b);
      b.SaveToFile(GetDestFile(F));
      Caption := Format('%s -> %s ok!', [umlGetFileName(itm.TagString).Text, umlGetFileName(GetDestFile(F)).Text]);
      DisposeObject(b);
    end;
  Caption := Format('all conver done!', []);
end;

procedure TBMPConverForm.FormCreate(Sender: TObject);
begin
  DestDirEdit.Text := umlCurrentPath;
end;

procedure TBMPConverForm.seldirEditButtonClick(Sender: TObject);
var
  v: string;
begin
  v := DestDirEdit.Text;
  if SelectDirectory('output directory', '', v) then
      DestDirEdit.Text := v;
end;

procedure TBMPConverForm.ListBoxChange(Sender: TObject);
var
  b: TMemoryRaster;
begin
  if ListBox.Selected = nil then
      exit;

  b := TMemoryRaster.Create;
  LoadMemoryBitmap(ListBox.Selected.TagString, b);
  b.DrawText(Format('%s' + #10 + 'width: %d * height: %d' + #10 + 'size:%s', [umlGetFileName(ListBox.Selected.TagString).Text,
    b.width, b.height, umlSizetoStr(umlGetFileSize(ListBox.Selected.TagString)).Text]),
    0, 0, Vec2(1.0, 0.0), -10, 0.9, 12, RasterColorF(1.0, 0.5, 0.5, 1));
  MemoryBitmapToBitmap(b, Image.Bitmap);
  DisposeObject(b);
end;

end.
