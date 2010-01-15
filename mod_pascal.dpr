library mod_pascal;

{$APPTYPE CONSOLE}

uses
  WebBroker,
  //CGIApp,
  ApacheTwoApp,
  uMain in 'uMain.pas' {PascalModule: TWebModule};

{$R *.res}
{$E so}

exports
  apache_module name 'mod_pascal_module';

begin
  Application.Initialize;
  Application.CreateForm(TPascalModule, PascalModule);
  Application.Run;
end.
