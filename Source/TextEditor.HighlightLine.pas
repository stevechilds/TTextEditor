﻿unit TextEditor.HighlightLine;

interface

uses
  System.Classes, System.UITypes, Vcl.Graphics, TextEditor.Types;

const
  TEXTEDITOR_HIGHLIGHT_LINE_DEFAULT_OPTIONS = [hlIgnoreCase, hlDeleteOnHighlighterLoad];

type
  TTextEditorHighlightLineItem = class(TCollectionItem)
  strict private
    FBackground: TColor;
    FForeground: TColor;
    FOptions: TTextEditorHighlightLineItemOptions;
    FPattern: string;
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(ACollection: TCollection); override;
    procedure Assign(ASource: TPersistent); override;
  published
    property Background: TColor read FBackground write FBackground default TColors.SysNone;
    property Foreground: TColor read FForeground write FForeground default TColors.SysNone;
    property Options: TTextEditorHighlightLineItemOptions read FOptions write FOptions default TEXTEDITOR_HIGHLIGHT_LINE_DEFAULT_OPTIONS;
    property Pattern: string read FPattern write FPattern;
  end;

  TTextEditorHighlightLineItems = class(TOwnedCollection)
  protected
    function GetItem(const AIndex: Integer): TTextEditorHighlightLineItem;
    procedure SetItem(const AIndex: Integer; const AValue: TTextEditorHighlightLineItem);
  public
    function Add: TTextEditorHighlightLineItem;
    function Insert(const AIndex: Integer): TTextEditorHighlightLineItem;
    property Items[const AIndex: Integer]: TTextEditorHighlightLineItem read GetItem write SetItem;
  end;

  TTextEditorHighlightLine = class(TPersistent)
  strict private
    FActive: Boolean;
    FItems: TTextEditorHighlightLineItems;
    FOwner: TPersistent;
    function GetItem(const AIndex: Integer): TTextEditorHighlightLineItem;
    function IsItemsStored: Boolean;
    procedure SetItems(const AValue: TTextEditorHighlightLineItems);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(const AOwner: TPersistent);
    destructor Destroy; override;
    procedure Assign(ASource: TPersistent); override;
    property Item[const AIndex: Integer]: TTextEditorHighlightLineItem read GetItem;
  published
    property Active: Boolean read FActive write FActive default False;
    property Items: TTextEditorHighlightLineItems read FItems write SetItems stored IsItemsStored;
  end;

implementation

uses
  System.StrUtils, TextEditor.Language;

{ TTextEditorHighlightLineItem }

constructor TTextEditorHighlightLineItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);

  FBackground := TColors.SysNone;
  FForeground := TColors.SysNone;
  FOptions := TEXTEDITOR_HIGHLIGHT_LINE_DEFAULT_OPTIONS;
end;

procedure TTextEditorHighlightLineItem.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TTextEditorHighlightLineItem) then
  with ASource as TTextEditorHighlightLineItem do
  begin
    Self.FBackground := FBackground;
    Self.FForeground := FForeground;
    Self.FOptions := FOptions;
    Self.FPattern := FPattern;
  end
  else
    inherited Assign(ASource);
end;

function TTextEditorHighlightLineItem.GetDisplayName: string;
begin
  Result := IfThen(FPattern = '', STextEditorHighlightLineItemUnnamed, FPattern);
end;

{ TTextEditorHighlightLineCollection }

function TTextEditorHighlightLineItems.GetItem(const AIndex: Integer): TTextEditorHighlightLineItem;
begin
  Result := TTextEditorHighlightLineItem(inherited GetItem(AIndex));
end;

procedure TTextEditorHighlightLineItems.SetItem(const AIndex: Integer; const AValue: TTextEditorHighlightLineItem);
begin
  inherited SetItem(AIndex, AValue);
end;

function TTextEditorHighlightLineItems.Add: TTextEditorHighlightLineItem;
begin
  Result := TTextEditorHighlightLineItem(inherited Add);
end;

function TTextEditorHighlightLineItems.Insert(const AIndex: Integer): TTextEditorHighlightLineItem;
begin
  Result := Add;
  Result.Index := AIndex;
end;

{ TTextEditorHighlightLine }

constructor TTextEditorHighlightLine.Create(const AOwner: TPersistent);
begin
  inherited Create;

  FOwner := AOwner;
  FActive := False;
  FItems := TTextEditorHighlightLineItems.Create(Self, TTextEditorHighlightLineItem);
end;

destructor TTextEditorHighlightLine.Destroy;
begin
  FItems.Free;

  inherited Destroy;
end;

procedure TTextEditorHighlightLine.Assign(ASource: TPersistent);
begin
  if Assigned(ASource) and (ASource is TTextEditorHighlightLine) then
  with ASource as TTextEditorHighlightLine do
  begin
    Self.FActive := FActive;
    Self.FItems.Assign(FItems);
  end
  else
    inherited Assign(ASource);
end;

function TTextEditorHighlightLine.IsItemsStored: Boolean;
begin
  Result := FItems.Count > 0;
end;

function TTextEditorHighlightLine.GetItem(const AIndex: Integer): TTextEditorHighlightLineItem;
begin
{$IFDEF TEXT_EDITOR_RANGE_CHECKS}
  if (AIndex < 0) or (AIndex > FItems.Count) then
    ListIndexOutOfBounds(AIndex);
{$ENDIF}
  Result := FItems.Items[AIndex];
end;

procedure TTextEditorHighlightLine.SetItems(const AValue: TTextEditorHighlightLineItems);
begin
  FItems.Assign(AValue);
end;

function TTextEditorHighlightLine.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

end.
