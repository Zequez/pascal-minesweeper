Unit MinesweeperUnit;

Interface
  Const
    BOARD_COLS = 50;
    BOARD_ROWS = 50;
    BOARD_MINES = 0.1;
  Type
    TileStateType = (tileFlag, tileEmpty, tileHidden, tileMine, tile1, tile2, tile3, tile4, tile5, tile6, tile7, tile8);
    BoardType = Array[1..BOARD_COLS, 1..BOARD_ROWS] of TileStateType;
    SiblingsCoordinatesType = Array[1..8, 1..2] of Byte;
    CoordinatesListType = Array[1..BOARD_COLS*BOARD_ROWS, 1..2] of Byte;
    BoardStatusType = (win, lost, playing);

  Function generateMinesBoard: BoardType;
  Function generatePlayerBoard: BoardType;
  Function minesAround(x: Integer; y: Integer; minesBoard: BoardType): Byte;
  Procedure drawTile(x: Byte; y: Byte; tileType: TileStateType; minesBoard: BoardType);
  Procedure drawBoard(playerBoard: BoardType; minesBoard: BoardType);
  Function toggleFlag(x: Byte; y: Byte; playerBoard: BoardType; minesBoard: BoardType): BoardType;
  Function pushCoordinates(x, y: Byte; var arr: SiblingsCoordinatesType; count: Byte): Byte;
  Function getSiblingTiles(x, y: Byte; cols: Byte; rows: Byte; var count: Byte): SiblingsCoordinatesType;
  Function activateSiblingTiles(siblingTiles: SiblingsCoordinatesType; siblingTilesLength: Byte; playerBoard, minesBoard: BoardType): BoardType;
  Function activateSiblingTiles(siblingTiles: SiblingsCoordinatesType; siblingTilesLength: Byte; playerBoard, minesBoard: BoardType; var checkedTiles: CoordinatesListType; var checkedTilesLength: Integer): BoardType;
  Function activateTile(x: Byte; y: Byte; playerBoard: BoardType; minesBoard: BoardType): BoardType;
  Function getBoardStatus(playerBoard: BoardType; minesBoard: BoardType): BoardStatusType;

Implementation
  Uses Crt, Keyboard;

  Function generateMinesBoard: BoardType;
    Var
      board: BoardType;
      i, j: Integer;
    Begin
      for i := 1 to BOARD_COLS do begin
        for j := 1 to BOARD_ROWS do begin
          if random < BOARD_MINES then
            board[i, j] := tileMine
          else
            board[i, j] := tileEmpty;
        end;
      end;

      generateMinesBoard := board;
    End;

  Function generatePlayerBoard: BoardType;
    Var
      board: BoardType;
      i, j: Integer;
    Begin
      for i := 1 to BOARD_COLS do begin
        for j := 1 to BOARD_ROWS do begin
          board[i, j] := tileHidden;
        end;
      end;

      generatePlayerBoard := board;
    End;

  Function minesAround(x: Integer;
                       y: Integer;
                       minesBoard: BoardType
                      ): Byte;
    Var
      mines: Byte;
    Begin
      mines := 0;

      if (x+1 <= BOARD_COLS)  and (minesBoard[x+1, y] = tileMine) then inc(mines);
      if (x-1 >= 1)            and (minesBoard[x-1, y] = tileMine) then inc(mines);
      if (y+1 <= BOARD_ROWS) and (minesBoard[x, y+1] = tileMine) then inc(mines);
      if (y-1 >= 1)            and (minesBoard[x, y-1] = tileMine) then inc(mines);

      if (x+1 <= BOARD_COLS) and (y+1 <= BOARD_ROWS)  and (minesBoard[x+1, y+1] = tileMine) then inc(mines);
      if (x-1 >= 1)           and (y-1 >= 1)             and (minesBoard[x-1, y-1] = tileMine) then inc(mines);
      if (x+1 <= BOARD_COLS) and (y-1 >= 1)             and (minesBoard[x+1, y-1] = tileMine) then inc(mines);
      if (x-1 >= 1)           and (y+1 <= BOARD_ROWS)  and (minesBoard[x-1, y+1] = tileMine) then inc(mines);

      minesAround := mines;
    End;

  Procedure drawTile(x: Byte;
                     y: Byte;
                     tileType: TileStateType;
                     minesBoard: BoardType);
    Var
      minesCount: Byte;
      prevX, prevY: Byte;
    Begin
      prevX := whereX;
      prevY := whereY;

      gotoXY(x, y);

      case tileType of
        tileFlag: write(#184);
        tileEmpty: begin
          minesCount := minesAround(x, y, minesBoard);
          if minesCount = 0 then write(' ')
          else begin
            case minesCount of
              1: TextColor(LightBlue);
              2: TextColor(Green);
              3: TextColor(LightRed);
              4: TextColor(Blue);
              5: TextColor(Red);
              6: TextColor(Brown);
              7: TextColor(Cyan);
              8: TextColor(Yellow);
            end;
            write(minesCount);
            TextColor(White);
          end;
        end;
        tileHidden: write(#178);
        tileMine: write(#254);
      end;

      gotoXY(prevX, prevY);
    End;

  Procedure drawBoard(playerBoard: BoardType;
                      minesBoard: BoardType);
    Var
      i, j: Integer;
    Begin
      for i := 1 to BOARD_COLS do begin
        for j := 1 to BOARD_ROWS do begin
          drawTile(i, j, playerBoard[i, j], minesBoard);
        end;
      end;
    End;

  Function toggleFlag(x: Byte;
                      y: Byte;
                      playerBoard: BoardType;
                      minesBoard: BoardType
                     ): BoardType;
    Begin
      if playerBoard[x, y] = tileFlag then
        playerBoard[x, y] := tileHidden
      else
        playerBoard[x, y] := tileFlag;

      drawTile(x, y, playerBoard[x, y], minesBoard);

      toggleFlag := playerBoard;
    End;

  // Function isTileConnected(fromX, fromY, toX, toY: Byte; minesBoard: BoardType): Boolean;
  //   Var
  //     i, j: Byte;
  //     visitedTiles: Array[1..BOARD_COLS*BOARD_ROWS, 1..2] of Byte;
  //   Begin
  //     for i := 1 to BOARD_COLS do begin
  //       for j := 1 to BOARD_ROWS do begin

  //       end;
  //     end;
  //     isTileConnected := true;
  //   End;

  Function pushCoordinates(x, 
                           y: Byte; 
                           var arr: SiblingsCoordinatesType;
                           count: Byte
                          ): Byte;
    Begin
      inc(count);
      arr[count, 1] := x;
      arr[count, 2] := y;
      pushCoordinates := count;
    End;

  Function getSiblingTiles(x, 
                           y: Byte; 
                           cols: Byte; 
                           rows: Byte; 
                           var count: Byte
                          ): SiblingsCoordinatesType;
    Var
      tiles: SiblingsCoordinatesType;
    Begin
      count := 0;

      if (x+1 <= cols)  then count := pushCoordinates(x+1, y, tiles, count);
      if (x-1 >= 1)     then count := pushCoordinates(x-1, y, tiles, count);
      if (y+1 <= rows)  then count := pushCoordinates(x, y+1, tiles, count);
      if (y-1 >= 1)     then count := pushCoordinates(x, y-1, tiles, count);

      if (x+1 <= cols) and (y+1 <= rows)  then count := pushCoordinates(x+1, y+1, tiles, count);
      if (x-1 >= 1)    and (y-1 >= 1)     then count := pushCoordinates(x-1, y-1, tiles, count);
      if (x+1 <= rows) and (y-1 >= 1)     then count := pushCoordinates(x+1, y-1, tiles, count);
      if (x-1 >= 1)    and (y+1 <= rows)  then count := pushCoordinates(x-1, y+1, tiles, count);

      getSiblingTiles := tiles;
    End;

  Function cleanSiblingTiles(siblingTiles: SiblingsCoordinatesType; 
                             siblingTilesLength: Byte; 
                             checkedTiles: CoordinatesListType;
                             checkedTilesLength: Integer;
                             var cleanSiblingTilesLength: Byte
                            ): SiblingsCoordinatesType;
    Var
      i, j: Integer;
      found: Boolean;
    Begin
      cleanSiblingTilesLength := 0;
      for i := 1 to siblingTilesLength do begin
        found := false;
        j := 1;
        repeat
          if (siblingTiles[i, 1] = checkedTiles[j, 1]) and (siblingTiles[i, 2] = checkedTiles[j, 2]) then begin
            found := true;
          end;
          inc(j);
        until found or (j > checkedTilesLength);

        if not found then begin
          inc(cleanSiblingTilesLength);
          cleanSiblingTiles[cleanSiblingTilesLength, 1] := siblingTiles[i, 1];
          cleanSiblingTiles[cleanSiblingTilesLength, 2] := siblingTiles[i, 2];
        end;
      end;


      // for j := 1 to subSiblingTilesLength do begin
      //   k := 0;
      //   found := false;
      //   while (not found) and (k < checkedTilesLength) do begin
      //     inc(k);
      //     if (subSiblingTiles[j, 1] = checkedTiles[k, 1]) and (subSiblingTiles[j, 2] = checkedTiles[k, 2]) then begin
      //       found := true;
      //     end;
      //   end;

      //   if (not found) then begin
      //     cleanSubSiblingTiles[cleanSubSiblingTilesLength] := 
      //   end;
      // end;
    End;

  Function activateSiblingTiles(siblingTiles: SiblingsCoordinatesType;
                                siblingTilesLength: Byte;
                                playerBoard,
                                minesBoard: BoardType
                               ): BoardType;
    Var
      checkedTiles: CoordinatesListType;
      checkedTilesLength: Integer;
    Begin
      activateSiblingTiles := activateSiblingTiles(siblingTiles, siblingTilesLength, playerBoard, minesBoard, checkedTiles, checkedTilesLength);
    End;

  Function activateSiblingTiles(siblingTiles: SiblingsCoordinatesType;
                                siblingTilesLength: Byte;
                                playerBoard,
                                minesBoard: BoardType;
                                var checkedTiles: CoordinatesListType;
                                var checkedTilesLength: Integer
                               ): BoardType;
    Var
      i, j, k: Byte;
      tile: Array[1..2] of Byte;
      sX, sY: Byte;
      subSiblingTiles, cleanSubSiblingTiles: SiblingsCoordinatesType;
      subSiblingTilesLength, cleanSubSiblingTilesLength: Byte;
      found: Boolean;
    Begin
      for i := 1 to siblingTilesLength do begin
        sX := siblingTiles[i, 1];
        sY := siblingTiles[i, 2];
        if minesBoard[sX, sY] <> tileMine then playerBoard[sX, sY] := tileEmpty;
        drawTile(sX, sY, playerBoard[sX, sY], minesBoard);
        if (minesBoard[sX, sY] = tileEmpty) and (minesAround(sX, sY, minesBoard) = 0) then begin
          subSiblingTiles := getSiblingTiles(sX, sY, BOARD_COLS, BOARD_ROWS, subSiblingTilesLength);
          subSiblingTiles := cleanSiblingTiles(subSiblingTiles, subSiblingTilesLength, checkedTiles, checkedTilesLength, subSiblingTilesLength);
          for j := 1 to subSiblingTilesLength do begin
            inc(checkedTilesLength);
            checkedTiles[checkedTilesLength, 1] := subSiblingTiles[j, 1];
            checkedTiles[checkedTilesLength, 2] := subSiblingTiles[j, 2];
          end;
          playerBoard := activateSiblingTiles(subSiblingTiles, subSiblingTilesLength, playerBoard, minesBoard, checkedTiles, checkedTilesLength);
        end;
      end;

      activateSiblingTiles := playerBoard;
    End;

  Function activateTile(x: Byte; 
                        y: Byte; 
                        playerBoard: BoardType; 
                        minesBoard: BoardType
                       ): BoardType;
    Var
      i, j: Byte;
      siblingTiles: SiblingsCoordinatesType;
      siblingTilesLength: Byte;
      sX, sY: Byte;
    Begin
      case playerBoard[x, y] of
        tileHidden, tileFlag: begin
          playerBoard[x, y] := minesBoard[x, y];
          drawTile(x, y, playerBoard[x, y], minesBoard);
        end;
      end;

      if (playerBoard[x, y] <> tileMine) and (minesAround(x, y, minesBoard) = 0) then begin
        siblingTiles := getSiblingTiles(x, y, BOARD_COLS, BOARD_ROWS, siblingTilesLength);
        playerBoard := activateSiblingTiles(siblingTiles, siblingTilesLength, playerBoard, minesBoard);
      end;

      activateTile := playerBoard;
    End;

  Function getBoardStatus(playerBoard, 
                          minesBoard: BoardType
                         ): BoardStatusType;
    Var
      i, j: Byte;
      hasLost, hasWon: Boolean;
      minesCount, hiddenCount: Integer;
    Begin
      hasLost := false;

      i := 1;
      j := 1;
      minesCount := 0;
      hiddenCount := 0;
      repeat
        repeat
          if playerBoard[i, j] = tileMine then hasLost := true;
          if playerBoard[i, j] = tileHidden then inc(hiddenCount);
          if minesBoard[i, j] = tileMine then inc(minesCount);
          inc(j);
        until (j > BOARD_COLS) or hasLost;
        inc(i);
      until (i > BOARD_COLS) or hasLost;

      if hasLost then getBoardStatus := lost
      else if minesCount = hiddenCount then getBoardStatus := win
      else getBoardStatus := playing;
    End;

Begin

End.