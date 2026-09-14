unit uUtils;

interface

uses System.SysUtils;

type
  EValidacao = class(Exception);

function SomenteNumeros(const AValor: string): string;
procedure Exigir(ACondicao: Boolean; const AMensagem: string);
procedure ValidarId(AId: Int64; const ACampo: string);
function DataSQL(const AValor: TDateTime): string;
function LerDataSQL(const AValor: string): TDateTime;

implementation

uses System.DateUtils;

function SomenteNumeros(const AValor: string): string;
var
  C: Char;
begin
  Result := '';
  for C in AValor do
    if CharInSet(C, ['0'..'9']) then
      Result := Result + C;
end;

procedure Exigir(ACondicao: Boolean; const AMensagem: string);
begin
  if not ACondicao then
    raise EValidacao.Create(AMensagem);
end;

procedure ValidarId(AId: Int64; const ACampo: string);
begin
  Exigir(AId > 0, ACampo + ' deve ser um identificador positivo.');
end;

function DataSQL(const AValor: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', AValor);
end;

function LerDataSQL(const AValor: string): TDateTime;
begin
  if AValor = '' then
    Exit(0);
  if not TryISO8601ToDate(AValor, Result, [ioNoTZIsLocal]) then
    raise EConvertError.Create('Data invalida no banco: ' + AValor);
end;

end.
