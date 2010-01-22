unit uMain;

interface

uses
  SysUtils, Classes, HTTPApp, uPSUtils, uPSComponent, uPSCompiler, uPSRuntime;

type
  TPascalModule = class(TWebModule)
    ScriptEngine: TPSScript;
    procedure PascalModuleScriptMainAction(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure ScriptEngineCompile(Sender: TPSScript);
    procedure ScriptEngineCompImport(Sender: TObject; x: TPSPascalCompiler);
    procedure ScriptEngineExecImport(Sender: TObject; se: TPSExec;
      x: TPSRuntimeClassImporter);
    procedure ScriptEngineExecute(Sender: TPSScript);
    function ScriptEngineFindUnknownFile(Sender: TObject;
      const OrginFileName: AnsiString; var FileName,
      Output: AnsiString): Boolean;
  private
    FRequest: TWebRequest;
    FResponse: TWebResponse;
    FResponseStream: TStringStream;
    FDefaultEncoding: string;
    FScriptRoot: string;
    procedure WriteLn(const S: string);
    function GetUtf8Encoding: TEncoding;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  PascalModule: TPascalModule;

implementation

uses
  uPSR_std,
  uPSC_std,
  uPSR_dateutils,
  uPSC_dateutils,
  uPSR_stdctrls,
  uPSC_stdctrls,
  uPSC_graphics,
  uPSC_controls,
  uPSC_classes,
  uPSR_graphics,
  uPSR_controls,
  uPSR_classes,
  uPSI_ApacheTwoApp,
  uPSI_HTTPApp;

{$R *.dfm}

{ TPascalModule }
constructor TPascalModule.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRequest := nil;
  FResponse := nil;
  FDefaultEncoding := 'utf-8';
  { パスを取得 }
  FScriptRoot := GetEnvironmentVariable('PASCAL_SCRIPT_ROOT');
end;

procedure TPascalModule.WriteLn(const S: string);
begin
  FResponse.Content := FResponse.Content + S + #13#10;
end;

function TPascalModule.GetUtf8Encoding: TEncoding;
begin
  Result := TEncoding.GetEncoding(65001);
end;

procedure TPascalModule.PascalModuleScriptMainAction(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
var
  ScriptPath, Messages: string;
  Compiled: Boolean;
  i: Integer;
begin
  { リクエストとレスポンスを保持 }
  FRequest := Request;
  FResponse := Response;
  { レスポンスヘッダの設定 }
  Response.ContentEncoding := FDefaultEncoding;
  try
    { スクリプト読み込み }
    ScriptPath :=  FScriptRoot + '\index.rops';
    try
      ScriptEngine.Script.LoadFromFile(ScriptPath, GetUtf8Encoding);
      { コンパイル }
      Compiled := ScriptEngine.Compile;
      for i := 0 to ScriptEngine.CompilerMessageCount -1 do
        Messages := Messages +
                    ScriptEngine.CompilerMessages[i].MessageToString +
                    #13#10;
      { 実行 }
      if Compiled then
        ScriptEngine.Execute
      else
      begin
        Response.StatusCode := 500;
        Response.Content := 'compile error:'#13#10+Messages;
      end;
    except
      Response.StatusCode := 500;
      Response.Content := ScriptPath;
    end;
    if Response.Content <> '' then
    begin
      FResponseStream := TStringStream.Create(Response.Content, GetUtf8Encoding);
      FResponseStream.Position := 0;
      Response.ContentStream := FResponseStream;
      Response.SendResponse;
    end;
  finally
    FResponseStream.Free;
    FRequest := nil;
    FResponse := nil;
  end;
end;

procedure TPascalModule.ScriptEngineCompile(Sender: TPSScript);
begin
  Sender.AddMethod(Self, @TPascalModule.WriteLn, 'procedure WriteLn(const S: string);');
  Sender.AddRegisteredPTRVariable('Request', 'TWebRequest');
  Sender.AddRegisteredPTRVariable('Response', 'TWebResponse');
end;

procedure TPascalModule.ScriptEngineCompImport(Sender: TObject;
  x: TPSPascalCompiler);
begin
  SIRegister_Std(x);
  RegisterDatetimeLibrary_C(x);
  SIRegister_Classes(x, true);
  SIRegister_Graphics(x, true);
  SIRegister_Controls(x);
  SIRegister_stdctrls(x);
  SIRegister_ApacheTwoApp(x);
  SIRegister_HTTPApp(x);
end;

procedure TPascalModule.ScriptEngineExecImport(Sender: TObject; se: TPSExec;
  x: TPSRuntimeClassImporter);
begin
  RIRegister_Std(x);
  RegisterDateTimeLibrary_R(se);
  RIRegister_Classes(x, True);
  RIRegister_Graphics(x, True);
  RIRegister_Controls(x);
  RIRegister_stdctrls(x);
  RIRegister_ApacheTwoApp(x);
  RIRegister_HTTPApp(x);
end;

procedure TPascalModule.ScriptEngineExecute(Sender: TPSScript);
begin
  ScriptEngine.SetPointerToData('Request', @FRequest, ScriptEngine.FindNamedType('TWebRequest'));
  ScriptEngine.SetPointerToData('Response', @FResponse, ScriptEngine.FindNamedType('TWebResponse'));
end;

function TPascalModule.ScriptEngineFindUnknownFile(Sender: TObject;
  const OrginFileName: AnsiString; var FileName, Output: AnsiString): Boolean;
var
  Buffer: TStringList;
  ScriptPath: string;
begin
  { usesで不明なファイルの処理 }
  ScriptPath := FScriptRoot + '\' + FileName + '.rops';
  if FileExists(ScriptPath) then
  begin
    Buffer := TStringList.Create;
    try
      Buffer.LoadFromFile(ScriptPath, GetUtf8Encoding);
      Output := Buffer.Text;
    finally
      Buffer.Free;
    end;
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

end.
