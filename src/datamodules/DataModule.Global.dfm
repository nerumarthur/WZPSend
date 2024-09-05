object DmGlobal: TDmGlobal
  OnCreate = DataModuleCreate
  Height = 480
  Width = 640
  object FDConnection: TFDConnection
    BeforeConnect = FDConnectionBeforeConnect
    Left = 72
    Top = 48
  end
  object qryInsertMensagem: TFDQuery
    Connection = FDConnection
    Left = 168
    Top = 48
  end
  object driverSQLite: TFDPhysSQLiteDriverLink
    Left = 272
    Top = 48
  end
  object qryConsulta: TFDQuery
    Connection = FDConnection
    Left = 72
    Top = 144
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Console'
    Left = 184
    Top = 144
  end
  object qryBaixaFila: TFDQuery
    Connection = FDConnection
    Left = 80
    Top = 224
  end
end
