Unit MinesweeperUnit;

Interface
  Const
    MAX_BOARD_COLS = 79;
    MAX_BOARD_ROWS = 23;
    MAX_BOARD_MINES = 150;
  Type
    TileStateType = (tileFlag, tileEmpty, tileHidden, tileMine); {tile1 , tile2, tile3, tile4, tile5, tile6, tile7, tile8);}
    BoardType = Array[1..MAX_BOARD_COLS, 1..MAX_BOARD_ROWS] of TileStateType;
    SiblingsCoordinatesType = Array[1..8, 1..2] of Integer;
    CoordinatesListType = Array[1..2000, 1..2] of Integer;
    BoardStatusType = (won, lost, playing, quitted);
    BoardConfigType = Record
      rows, cols, mines: Integer;
    End;

  Function generateMinesBoard(boardConfig: BoardConfigType): BoardType;
  Function generatePlayerBoard(boardConfig: BoardConfigType): BoardType;
  Function minesAround(x: Integer; y: Integer; minesBoard: BoardType; boardConfig: BoardConfigType): Integer;
  Procedure drawTile(x: Integer; y: Integer; tileType: TileStateType; minesBoard: BoardType; boardConfig: BoardConfigType);
  Procedure drawTile(x: Integer; y: Integer; tileType: TileStateType; minesBoard: BoardType; boardConfig: BoardConfigType; startX, startY: Integer);
  Procedure drawBoard(playerBoard: BoardType; minesBoard: BoardType; boardConfig: BoardConfigType; startX, startY: Integer);
  Function toggleFlag(x: Integer; y: Integer; playerBoard: BoardType; minesBoard: BoardType; boardConfig: BoardConfigType): BoardType;
  Function pushCoordinates(x, y: Integer; var arr: SiblingsCoordinatesType; count: Integer): Integer;
  Function getSiblingTiles(x, y: Integer; cols: Integer; rows: Integer; var count: Integer): SiblingsCoordinatesType;
  Function activateSiblingTiles(siblingTiles: SiblingsCoordinatesType; siblingTilesLength: Integer; playerBoard, minesBoard: BoardType; boardConfig: BoardConfigType): BoardType;
  Function activateSiblingTiles(siblingTiles: SiblingsCoordinatesType; siblingTilesLength: Integer; playerBoard, minesBoard: BoardType; var checkedTiles: CoordinatesListType; var checkedTilesLength: Integer; boardConfig: BoardConfigType): BoardType;
  Function activateTile(x: Integer; y: Integer; playerBoard: BoardType; minesBoard: BoardType; boardConfig: BoardConfigType): BoardType;
  Function getBoardStatus(playerBoard: BoardType; minesBoard: BoardType; boardConfig: BoardConfigType): BoardStatusType;
  Function resolveBoard(playerBoard, minesBoard: BoardType; boardConfig: BoardConfigType): BoardType;
  Function startNewGame(boardMines, boardRows, boardCols: Integer): BoardStatusType;

Implementation
  Uses Crt, Math;

  Function generateMinesBoard(boardConfig: BoardConfigType): BoardType;
    Var
      board: BoardType;
      i, j: Integer;
      mineX, mineY: Integer;
    Begin
      for i := 1 to boardConfig.cols do begin
        for j := 1 to boardConfig.rows do begin
          board[i, j] := tileEmpty;
        end;
      end;

      for i := 1 to boardConfig.mines do begin
        repeat
          mineX := floor(boardConfig.cols*random+1);
          mineY := floor(boardConfig.rows*random+1);
        until board[mineX, mineY] <> tileMine;
        board[mineX, mineY] := tileMine;
      end;

      generateMinesBoard := board;
    End;

  Function generatePlayerBoard(boardConfig: BoardConfigType): BoardType;
    Var
      board: BoardType;
      i, j: Integer;
    Begin
      for i := 1 to boardConfig.cols do begin
        for j := 1 to boardConfig.rows do begin
          board[i, j] := tileHidden;
        end;
      end;

      generatePlayerBoard := board;
    End;

  Function minesAround(x: Integer;
                       y: Integer;
                       minesBoard: BoardType;
                       boardConfig: BoardConfigType
                      ): Integer;
    Var
      mines: Integer;
    Begin
      mines := 0;

      if (x+1 <= boardConfig.cols) and (minesBoard[x+1, y] = tileMine) then inc(mines);
      if (x-1 >= 1)                and (minesBoard[x-1, y] = tileMine) then inc(mines);
      if (y+1 <= boardConfig.rows) and (minesBoard[x, y+1] = tileMine) then inc(mines);
      if (y-1 >= 1)                and (minesBoard[x, y-1] = tileMine) then inc(mines);

      if (x+1 <= boardConfig.cols) and (y+1 <= boardConfig.rows)  and (minesBoard[x+1, y+1] = tileMine) then inc(mines);
      if (x-1 >= 1)                and (y-1 >= 1)                 and (minesBoard[x-1, y-1] = tileMine) then inc(mines);
      if (x+1 <= boardConfig.cols) and (y-1 >= 1)                 and (minesBoard[x+1, y-1] = tileMine) then inc(mines);
      if (x-1 >= 1)                and (y+1 <= boardConfig.rows)  and (minesBoard[x-1, y+1] = tileMine) then inc(mines);

      minesAround := mines;
    End;

  Procedure drawTile(x: Integer;
                   y: Integer;
                   tileType: TileStateType;
                   minesBoard: BoardType;
                   boardConfig: BoardConfigType
                  );
    Begin
      drawTile(x, y, tileType, minesBoard, boardConfig, 0, 0);
    End;

  Procedure drawTile(x: Integer;
                     y: Integer;
                     tileType: TileStateType;
                     minesBoard: BoardType;
                     boardConfig: BoardConfigType;
                     startX,
                     startY: Integer
                    );
    Var
      minesCount: Integer;
      prevX, prevY: Integer;
    Begin
      prevX := whereX;
      prevY := whereY;

      gotoXY(startX + x, startY + y);

      TextColor(White);
      case tileType of
        tileFlag: write(#184);
        tileEmpty: begin
          minesCount := minesAround(x, y, minesBoard, boardConfig);
          if minesCount = 0 then write(' ')
          else begin
            case minesCount of
              1: TextColor(LightBlue);
              2: TextColor(Green);
              3: TextColor(LightRed);
              4: TextColor(Yellow);
              5: TextColor(Red);
              6: TextColor(Brown);
              7: TextColor(Cyan);
              8: TextColor(Blue);
            end;
            write(minesCount);
          end;
        end;
        tileHidden: begin
          TextColor(DarkGray);
          write(#178);
        end;
        tileMine: write(#254);
      end;
      TextColor(DarkGray);

      gotoXY(prevX, prevY);
    End;

  Procedure drawBoard(playerBoard: BoardType;
                      minesBoard: BoardType;
                      boardConfig: BoardConfigType;
                      startX,
                      startY: Integer);
    Var
      i, j: Integer;
    Begin
      for i := 1 to boardConfig.cols do begin
        for j := 1 to boardConfig.rows do begin
          drawTile(i, j, playerBoard[i, j], minesBoard, boardConfig, startX, startY);
        end;
      end;
    End;

  Function toggleFlag(x: Integer;
                      y: Integer;
                      playerBoard: BoardType;
                      minesBoard: BoardType;
                      boardConfig: BoardConfigType
                     ): BoardType;
    Begin
      if playerBoard[x, y] = tileFlag then
        playerBoard[x, y] := tileHidden
      else if playerBoard[x, y] = tileHidden then
        playerBoard[x, y] := tileFlag;

      drawTile(x, y, playerBoard[x, y], minesBoard, boardConfig);

      toggleFlag := playerBoard;
    End;

  Function pushCoordinates(x, 
                           y: Integer; 
                           var arr: SiblingsCoordinatesType;
                           count: Integer
                          ): Integer;
    Begin
      inc(count);
      arr[count, 1] := x;
      arr[count, 2] := y;
      pushCoordinates := count;
    End;

  Function getSiblingTiles(x, 
                           y: Integer; 
                           cols: Integer; 
                           rows: Integer; 
                           var count: Integer
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
                             siblingTilesLength: Integer; 
                             checkedTiles: CoordinatesListType;
                             checkedTilesLength: Integer;
                             var cleanSiblingTilesLength: Integer
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
    End;

  Function activateSiblingTiles(siblingTiles: SiblingsCoordinatesType;
                                siblingTilesLength: Integer;
                                playerBoard,
                                minesBoard: BoardType;
                                boardConfig: BoardConfigType
                               ): BoardType;
    Var
      checkedTiles: CoordinatesListType;
      checkedTilesLength: Integer;
    Begin
      activateSiblingTiles := activateSiblingTiles(siblingTiles, siblingTilesLength, playerBoard, minesBoard, checkedTiles, checkedTilesLength, boardConfig);
    End;

  Function activateSiblingTiles(siblingTiles: SiblingsCoordinatesType;
                                siblingTilesLength: Integer;
                                playerBoard,
                                minesBoard: BoardType;
                                var checkedTiles: CoordinatesListType;
                                var checkedTilesLength: Integer;
                                boardConfig: BoardConfigType
                               ): BoardType;
    Var
      i, j, k: Integer;
      tile: Array[1..2] of Integer;
      sX, sY: Integer;
      subSiblingTiles, cleanSubSiblingTiles: SiblingsCoordinatesType;
      subSiblingTilesLength, cleanSubSiblingTilesLength: Integer;
      found: Boolean;
    Begin
      for i := 1 to siblingTilesLength do begin
        sX := siblingTiles[i, 1];
        sY := siblingTiles[i, 2];
        if minesBoard[sX, sY] <> tileMine then playerBoard[sX, sY] := tileEmpty;
        drawTile(sX, sY, playerBoard[sX, sY], minesBoard, boardConfig);
        if (minesBoard[sX, sY] = tileEmpty) and (minesAround(sX, sY, minesBoard, boardConfig) = 0) then begin
          subSiblingTiles := getSiblingTiles(sX, sY, boardConfig.cols, boardConfig.rows, subSiblingTilesLength);
          subSiblingTiles := cleanSiblingTiles(subSiblingTiles, subSiblingTilesLength, checkedTiles, checkedTilesLength, subSiblingTilesLength);
          for j := 1 to subSiblingTilesLength do begin
            inc(checkedTilesLength);
            checkedTiles[checkedTilesLength, 1] := subSiblingTiles[j, 1];
            checkedTiles[checkedTilesLength, 2] := subSiblingTiles[j, 2];
          end;
          playerBoard := activateSiblingTiles(subSiblingTiles, subSiblingTilesLength, playerBoard, minesBoard, checkedTiles, checkedTilesLength, boardConfig);
        end;
      end;

      activateSiblingTiles := playerBoard;
    End;

  Function activateTile(x: Integer; 
                        y: Integer; 
                        playerBoard: BoardType; 
                        minesBoard: BoardType;
                        boardConfig: BoardConfigType
                       ): BoardType;
    Var
      i, j: Integer;
      siblingTiles: SiblingsCoordinatesType;
      siblingTilesLength: Integer;
      sX, sY: Integer;
    Begin
      case playerBoard[x, y] of
        tileHidden, tileFlag: begin
          playerBoard[x, y] := minesBoard[x, y];
          drawTile(x, y, playerBoard[x, y], minesBoard, boardConfig);
        end;
      end;

      if (playerBoard[x, y] <> tileMine) and (minesAround(x, y, minesBoard, boardConfig) = 0) then begin
        siblingTiles := getSiblingTiles(x, y, boardConfig.cols, boardConfig.rows, siblingTilesLength);
        playerBoard := activateSiblingTiles(siblingTiles, siblingTilesLength, playerBoard, minesBoard, boardConfig);
      end;

      activateTile := playerBoard;
    End;

  Function getBoardStatus(playerBoard,
                          minesBoard: BoardType;
                          boardConfig: BoardConfigType
                         ): BoardStatusType;
    Var
      i, j, k, l: Integer;
      hasLost: Boolean;
      emptyCount: Integer;
      newBoardStatus: BoardStatusType;
    Begin
      hasLost := false;
      i := 1;
      emptyCount := 0;
      repeat
        j := 1;
        repeat
          if playerBoard[i, j] = tileMine then hasLost := true;
          if playerBoard[i, j] = tileEmpty then inc(emptyCount);
          inc(j);
        until (j > boardConfig.rows) or hasLost;
        inc(i);
      until (i > boardConfig.cols) or hasLost;

      gotoXY(1, boardConfig.rows+1);

      if hasLost then newBoardStatus := lost
      else if boardConfig.mines = (boardConfig.cols*boardConfig.rows - emptyCount) then newBoardStatus := won
      else newBoardStatus := playing;

      getBoardStatus := newBoardStatus;
    End;

  Function resolveBoard(playerBoard,
                        minesBoard: BoardType;
                        boardConfig: BoardConfigType
                        ): BoardType;
    Var
      i, j: Integer;
    Begin
      for i := 1 to boardConfig.cols do begin
        for j := 1 to boardConfig.rows do begin
          if minesBoard[i, j] = tileMine then begin
            drawTile(i, j, tileMine, minesBoard, boardConfig);
          end;
        end;
      end;
    End;

  Function startNewGame(boardMines, boardRows, boardCols: Integer): BoardStatusType;
    Var
      minesBoard, playerBoard: BoardType;
      i, j: Integer;
      key: Char;
      cursorX, cursorY: Integer;
      boardStatus: BoardStatusType;
      boardConfig: BoardConfigType;
    Begin
      boardConfig.mines := boardMines;
      boardConfig.rows := boardRows;
      boardConfig.cols := boardCols;

      minesBoard := generateMinesBoard(boardConfig);
      playerBoard := generatePlayerBoard(boardConfig);
      drawBoard(playerBoard, minesBoard, boardConfig, 0, 0);
      // drawBoard(minesBoard, minesBoard, boardConfig, boardConfig.cols, 0);
      boardStatus := playing;
    
      cursorX := 1;
      cursorY := 1;
      repeat
        gotoXY(cursorX, cursorY);
        key := readKey;

        case key of
          #75 : if cursorX > 1                then dec(cursorX); {Left}
          #77 : if cursorX < boardConfig.cols then inc(cursorX); {Right}
          #72 : if cursorY > 1                then dec(cursorY); {Up}
          #80 : if cursorY < boardConfig.rows then inc(cursorY); {Down}
          'f': playerBoard := toggleFlag(cursorX, cursorY, playerBoard, minesBoard, boardConfig);
          ' ': playerBoard := activateTile(cursorX, cursorY, playerBoard, minesBoard, boardConfig);
        end;

        boardStatus := getBoardStatus(playerBoard, minesBoard, boardConfig);
      until (key = #27) or (key = 'q') or (boardStatus <> playing);

      resolveBoard(playerBoard, minesBoard, boardConfig);

      gotoXY(1, boardConfig.rows+1);

      startNewGame := boardStatus;
    End;

Begin

End.