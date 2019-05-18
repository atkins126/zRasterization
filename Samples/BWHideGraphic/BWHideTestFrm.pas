unit BWHideTestFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls,

  CoreClasses, PascalStrings, UnicodeMixedLib, ListEngine,
  Geometry2DUnit, MemoryRaster, zDrawEngine, zDrawEngineInterface_FMX,
  FMX.Layouts, FMX.ExtCtrls;

type
  TBWHideTestForm = class(TForm)
    sour1: TImage;
    sour2: TImage;
    Label1: TLabel;
    Label3: TLabel;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Label2: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Button1: TButton;
    ColorCheckBox: TCheckBox;
    TrackBarGAMMA: TTrackBar;
    test2: TImageViewer;
    test1: TImageViewer;
    procedure Button1Click(Sender: TObject);
    procedure ColorCheckBoxChange(Sender: TObject);
    procedure sour1Click(Sender: TObject);
    procedure sour2Click(Sender: TObject);
    procedure TrackBarGAMMAChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoBuildOutput;
  end;

var
  BWHideTestForm: TBWHideTestForm;

procedure HideTechPrototype(w, h: Integer; gray: Boolean; gamma: ShortInt; t1, t2, final_output: TMemoryRaster);
procedure HideTechBuild(gray: Boolean; gamma: ShortInt; r1, r2, final_output: TMemoryRaster);
procedure FMX_HideTechBuild(gray: Boolean; gamma: ShortInt; t1, t2, output: TBitmap);

implementation

{$R *.fmx}


procedure HideTechPrototype(w, h: Integer; gray: Boolean; gamma: ShortInt; t1, t2, final_output: TMemoryRaster);
  function Clamp(const Value: Integer; Min, Max: Byte): Byte; overload;
  begin
    if Value > Max then
        Result := Max
    else if Value < Min then
        Result := Min
    else
        Result := Value;
  end;

  function Clamp(const Value: Integer): Byte; overload;
  begin
    if Value > 255 then
        Result := 255
    else if Value < 0 then
        Result := 0
    else
        Result := Value;
  end;

var
  fi, fj: Boolean;
  i, j: Integer;
  c: TRasterColor;
  e: TRasterColorEntry;
begin
  fi := True;
  i := 0;
  while i < w do
    begin
      fi := not fi;
      fj := fi;
      j := 0;
      while j < h do
        begin
          if fj then
            begin
              if gray then
                  c := RasterColor($FF, $FF, $FF, t1.PixelGray[i, j])
              else
                begin
                  e.BGRA := t1.Pixel[i, j];
                  e.a := Clamp(RasterColor2Gray(e.BGRA) + gamma);
                  e.b := Clamp(e.b);
                  e.g := Clamp(e.g);
                  e.r := Clamp(e.r);
                  c := e.BGRA;
                end;
            end
          else
            begin
              c := RasterColor($00, $00, $00, $FF - t2.PixelGray[i, j])
            end;

          fj := not fj;
          final_output.Pixel[i, j] := c;
          inc(j);
        end;
      inc(i);
    end;
end;

procedure HideTechBuild(gray: Boolean; gamma: ShortInt; r1, r2, final_output: TMemoryRaster);
var
  mx, my: Integer;
  n1, n2: TMemoryRaster;
  dr: TRectV2;
begin
  mx := umlMax(r1.Width, r2.Width);
  my := umlMax(r1.Height, r2.Height);

  n1 := NewRaster();
  n1.SetSize(mx, my, RasterColorF(0, 0, 0, 1));
  r1.ProjectionTo(n1, r1.BoundsRectV2, RectFit(r1.BoundsRectV2, n1.BoundsRectV2), True, 1.0);

  n2 := NewRaster();
  n2.SetSize(mx, my, RasterColorF(1, 1, 1, 1));
  r2.ProjectionTo(n2, r2.BoundsRectV2, RectFit(r2.BoundsRectV2, n2.BoundsRectV2), True, 1.0);

  if not gray then
      HistogramEqualize(n1, n2);

  final_output.SetSize(mx, my);
  HideTechPrototype(mx, my, gray, gamma, n1, n2, final_output);
  disposeObject([n1, n2]);
end;

procedure FMX_HideTechBuild(gray: Boolean; gamma: ShortInt; t1, t2, output: TBitmap);
var
  r1, r2, final_output: TMemoryRaster;
  tmp: TMemoryRaster;
begin
  r1 := NewRaster();
  r2 := NewRaster();
  final_output := NewRaster();
  BitmapToMemoryBitmap(t1, r1);
  BitmapToMemoryBitmap(t2, r2);
  HideTechBuild(gray, gamma, r1, r2, final_output);
  MemoryBitmapToBitmap(final_output, output);
  disposeObject([r1, r2, final_output]);
end;

constructor TBWHideTestForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OpenDialog1.Filter := TBitmapCodecManager.GetFilterString;
  DoBuildOutput;
end;

destructor TBWHideTestForm.Destroy;
begin
  inherited Destroy;
end;

procedure TBWHideTestForm.Button1Click(Sender: TObject);
var
  r1, r2, final_output: TMemoryRaster;
begin
  if not SaveDialog1.Execute then
      exit;

  r1 := NewRaster();
  r2 := NewRaster();
  final_output := NewRaster();
  BitmapToMemoryBitmap(sour1.Bitmap, r1);
  BitmapToMemoryBitmap(sour2.Bitmap, r2);
  HideTechBuild(not ColorCheckBox.IsChecked, Trunc(TrackBarGAMMA.Value), r1, r2, final_output);

  SaveMemoryBitmap(SaveDialog1.FileName, final_output);

  disposeObject([r1, r2, final_output]);
end;

procedure TBWHideTestForm.ColorCheckBoxChange(Sender: TObject);
begin
  DoBuildOutput;
end;

procedure TBWHideTestForm.DoBuildOutput;
var
  r1, r2, final_output: TMemoryRaster;
  tmp: TMemoryRaster;
begin
  r1 := NewRaster();
  r2 := NewRaster();
  final_output := NewRaster();
  BitmapToMemoryBitmap(sour1.Bitmap, r1);
  BitmapToMemoryBitmap(sour2.Bitmap, r2);
  HideTechBuild(not ColorCheckBox.IsChecked, Trunc(TrackBarGAMMA.Value), r1, r2, final_output);

  tmp := NewRaster();
  tmp.SetSize(final_output.Width, final_output.Height, RasterColor($FF, $FF, $FF));
  final_output.DrawTo(tmp);
  MemoryBitmapToBitmap(tmp, test1.Bitmap);
  disposeObject(tmp);

  tmp := NewRaster();
  tmp.SetSize(final_output.Width, final_output.Height, RasterColor($0, $0, $0));
  final_output.DrawTo(tmp);
  MemoryBitmapToBitmap(tmp, test2.Bitmap);
  disposeObject(tmp);

  disposeObject([r1, r2, final_output]);
end;

procedure TBWHideTestForm.sour1Click(Sender: TObject);
begin
  if not OpenDialog1.Execute then
      exit;
  sour1.Bitmap.LoadFromFile(OpenDialog1.FileName);
  DoBuildOutput;
end;

procedure TBWHideTestForm.sour2Click(Sender: TObject);
begin
  if not OpenDialog1.Execute then
      exit;
  sour2.Bitmap.LoadFromFile(OpenDialog1.FileName);
  DoBuildOutput;
end;

procedure TBWHideTestForm.TrackBarGAMMAChange(Sender: TObject);
begin
  DoBuildOutput;
end;

end.
