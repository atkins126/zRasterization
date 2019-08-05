program BWHideTech;

uses
  System.StartUpCopy,
  FMX.Forms,
  BWHideTestFrm in 'BWHideTestFrm.pas' {BWHideTestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TBWHideTestForm, BWHideTestForm);
  Application.Run;
end.
