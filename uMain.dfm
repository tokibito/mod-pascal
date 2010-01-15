object PascalModule: TPascalModule
  OldCreateOrder = False
  Actions = <
    item
      Default = True
      Name = 'ScriptMain'
      PathInfo = '/'
      OnAction = PascalModuleScriptMainAction
    end>
  Height = 150
  Width = 215
  object ScriptEngine: TPSScript
    CompilerOptions = []
    OnCompile = ScriptEngineCompile
    OnExecute = ScriptEngineExecute
    OnCompImport = ScriptEngineCompImport
    OnExecImport = ScriptEngineExecImport
    Plugins = <>
    UsePreProcessor = False
    Left = 24
    Top = 12
  end
end
