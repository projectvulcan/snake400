      *==========================================================================================
      *                                                                      datacrush@gmail.com
      * GU007R
      * Snake/400 - Traditional snake game on iSeries
      *
      * Version 2 Release 1 Modifications 0
      *  March 2013
      * Version 1 Release 1 Modifications 0
      *  February 2003
      *
      * (C) Copyright Isaac Syaz, 2003-2013.
      * All Rights Reserved
      *
      *==========================================================================================
      * Modifications log
      * ----------------------------------------------------------------------------------------
      * Trace   User        Date        Description
      * ----------------------------------------------------------------------------------------
      *         SyazwanH    10/03/2013  Added computer opponent.
      *         SyazwanH    28/02/2003  Improved game speed and cursor accuracy.
      *         SyazwanH    16/02/2003  New program.
      * ----------------------------------------------------------------------------------------
      *==========================================================================================
      *
      * Instructions
      * ------------
      * There should be three files:
      *  GU007D *FILE        (DSPF)
      *  GU007R *PGM/*MODULE (RPGLE)
      *  GU007C *PGM         (CLLE)
      *
      * Compile GU007C as program. Compile GU007D as per normal.
      * Compile GU007R as module (CRTRPGMOD). Then type the following:
      *  CRTPGM PGM(GU007R) MODULE(GU007R) BNDDIR(QC2LE) ACTGRP(*CALLER) ALWLIBUPD(*YES)
      *
      * When running the program, make sure you have QTEMP in your library list.
      *  CALL PGM(GU007C)
      *
      *==========================================================================================
     H AltSeq(*None)
     H BndDir('QC2LE')
      *
     FGu007D    CF   E             WorkStn                                      Display file
      *
      *------------------------------------------------------------------------------------------
      * Prototype procedure
      *------------------------------------------------------------------------------------------
      *
     D GetRandom       Pr            10I 0 ExtProc('rand')                      ILE C procedure
      *
     D Sleep           Pr            10I 0 ExtProc('usleep')                    ILE C procedure
     D  SleepTime                    10I 0 Value
      *
      *------------------------------------------------------------------------------------------
      * System status data structure
      *------------------------------------------------------------------------------------------
      *
     D                SDs
     D  QMsgTyp               40     42                                         Message type
     D  QMsgNbr               43     46                                         Message number
      *
      *------------------------------------------------------------------------------------------
      * Local variables
      *------------------------------------------------------------------------------------------
      *
      * Information on snake's position
     D SnakePos        Ds           500    Inz                                  Snake on screen
     D  SnakePos_Arr                  1A   Dim(500)                             .In array
     D  SnakePos_Char          1    500A                                        .In string
      *
     D Snake_Cur_X     S             10I 0 Inz(*Zeros)                          Snake X Axis
     D Snake_Cur_Y     S             10I 0 Inz(*Zeros)                          Snake Y Axis
     D Snake_Length    S             10I 0 Inz(*Zeros)                          Snake length index
     D Snake_Grow      S             10I 0 Inz(*Zeros)                          Snake growth index
     D Snake_Food      S             10I 0 Inz(*Zeros)                          Snake food index
     D Snake_Heading   S              1A   Inz(*Blanks)                         Snake direction
      *
     D Snake_Prev_X    S             10I 0 Dim(500) Inz(*Zeros)                 Snake history of X
     D Snake_Prev_Y    S             10I 0 Dim(500) Inz(*Zeros)                 Snake history of Y
     D Snake_Prev_Cnt  S             10I 0 Inz(*Zeros)                          Snake history count
      *
     D Snake_Food_X    S             10I 0 Inz(*Zeros)
     D Snake_Food_Y    S             10I 0 Inz(*Zeros)
      *
      * Information on snake's position
     D Snak2_Cur_X     S             10I 0 Inz(*Zeros)                          Snake X Axis
     D Snak2_Cur_Y     S             10I 0 Inz(*Zeros)                          Snake Y Axis
     D Snak2_Length    S             10I 0 Inz(*Zeros)                          Snake length index
     D Snak2_Grow      S             10I 0 Inz(*Zeros)                          Snake growth index
     D Snak2_Food      S             10I 0 Inz(*Zeros)                          Snake food index
     D Snak2_Heading   S              1A   Inz(*Blanks)                         Snake direction
      *
     D Snak2_Prev_X    S             10I 0 Dim(500) Inz(*Zeros)                 Snake history of X
     D Snak2_Prev_Y    S             10I 0 Dim(500) Inz(*Zeros)                 Snake history of Y
     D Snak2_Prev_Cnt  S             10I 0 Inz(*Zeros)                          Snake history count
      *
     D Ind_EndGame     S              1N   Inz(*Off)                            End game indicator
      *
      * General calculations
     D Pos_X           S             10I 0 Inz(*Zeros)                          Position of X
     D Pos_Y           S             10I 0 Inz(*Zeros)                          Position of Y
     D Result          S             10I 0 Inz(*Zeros)                          Result
     D Time_LstMove    S               Z   Inz                                  Time of last move
     D Time_CurMove    S               Z   Inz                                  Time of current move
     D Time_Secs       S             10I 0 Inz(*Zeros)                          Time in seconds
     D Temp_Rand       S             10I 0 Inz(*Zeros)                          Random work field
     D User_Score      S             10I 0 Inz(*Zeros)                          Current score
     D Comp_Score      S             10I 0 Inz(*Zeros)                          Current score
     D Add_To_Tail     S             10I 0 Inz(*Zeros)                          Add length count
      *
      * Use with data queue
     D QNam            S             10A   Inz('GU007DQ')                       Queue Name
     D QLib            S             10A   Inz('*LIBL')                         Queue Library
     D QLen            S              5P 0 Inz(*Zeros)                          Queue Length
     D QMsg            S            640A   Inz(*Blanks)                         Queue Message
     D QWait           S              5P 0 Inz(1)                               Queue Wait
      *
      * Use with sleep
     D Warn            S             10I 0 Inz(*Zeros)
     D SleepTime       S             10I 0 Inz(300000)
      *
      *------------------------------------------------------------------------------------------
      * Parameters list
      *------------------------------------------------------------------------------------------
      *
     C     WRcvDtaq      Plist
     C                   Parm                    QNam                           Queue Name
     C                   Parm                    QLib                           Queue Library
     C                   Parm      *Zeros        QLen                           Queue Length
     C                   Parm      *Blanks       QMsg                           Queue Message
     C                   Parm      *Zeros        QWait                          Queue Wait
      *
      *------------------------------------------------------------------------------------------
      * Main logic
      *------------------------------------------------------------------------------------------
      *
     C                   ExSr      SrInit                                       Initialize program
      *
     C                   DoW       (*In03 = *Off) And (*In12 = *Off)
      *
     C                   ExSr      SrPutToScreen
      *
     C                   Write     D01                                  31
     C                   If        (*In31 = *On) And                            If error occurs
     C                             (QMsgTyp = 'CPF' And QMsgNbr = '4737')        on CPF4737
     C                   Read      D01                                          .Force READ
     C                   EndIf
      *
     C                   Call      'QRCVDTAQ'    WRcvDtaq                       Wait on data queue
      *
     C     #Repeat       Tag
     C                   If        (QLen > *Zeros)                              If there's message
     C                   Read      D01                                          .READ from screen
     C                   If        (*In03 = *On) Or (*In12 = *On)               Check indicators
     C                   Iter                                                   .Iterate
     C                   EndIf
     C                   Else
     C                   Eval      Warn = Sleep(SleepTime)                      Sleep
     C                   Call      'QRCVDTAQ'    WRcvDtaq                       Wait on data queue
     C                   If        (QLen > *Zeros)
     C                   Goto      #Repeat
     C                   EndIf
     C                   EndIf
      *
     C                   If        (Ind_EndGame = *Off)                         If game over don't
      *                                                                          execute
     C                   Time                    Time_CurMove                   Get time and compare
     C     Time_CurMove  SubDur    Time_LstMove  Time_Secs:*Ms                  last move time
     C                   If        (Time_Secs >= 299999)                        Should not be less
     C                   ExSr      SrCheckMove                                  than 1 seconds ago
     C                   ExSr      SrAutoMove                                   to valid for a move.
     C                   ExSr      SrAutoMov2                                   to valid for a move.
     C                   EndIf
      *
     C                   EndIf
      *
     C                   EndDo
      *
     C                   Move      *On           *Inlr
      *
      *------------------------------------------------------------------------------------------
      * SrCheckMove Sub Routine
      *  Check movement made
      *------------------------------------------------------------------------------------------
      *
     C     SrCheckMove   BegSr
      *
     C                   Eval      Time_LstMove = (Time_CurMove)
      *
     C                   Select
     C                   When      (WInput = 'I') And                           Move North
     C                             (Snake_Heading <> 'S')                       .Current not South
     C                   Movel(P)  'N'           Snake_Heading
     C                   When      (WInput = 'K') And                           Move South
     C                             (Snake_Heading <> 'N')                       .Current not North
     C                   Movel(P)  'S'           Snake_Heading
     C                   When      (WInput = 'J') And                           Move West
     C                             (Snake_Heading <> 'E')                       .Current not East
     C                   Movel(P)  'W'           Snake_Heading
     C                   When      (WInput = 'L') And                           Move East
     C                             (Snake_Heading <> 'W')                       .Current not West
     C                   Movel(P)  'E'           Snake_Heading
     C                   EndSl
      *
     C                   EndSr
      *
      *------------------------------------------------------------------------------------------
      * SrAutoMove Sub Routine
      *  Automatically move the snake forward
      *------------------------------------------------------------------------------------------
      *
     C     SrAutoMove    BegSr
      *
     C                   Eval      Snake_Cur_X = (Snake_Prev_X(1))              Get head X position
     C                   Eval      Snake_Cur_Y = (Snake_Prev_Y(1))              Get head Y position
      *
     C                   Select
     C                   When      (Snake_Heading = 'N')                        Move North
     C                   Sub       1             Snake_Cur_X
     C                   If        (Snake_Cur_X < 1)                            If greater
     C                   Z-Add     10            Snake_Cur_X                    .Then resize
     C                   EndIf
     C                   When      (Snake_Heading = 'S')                        Move South
     C                   Add       1             Snake_Cur_X
     C                   If        (Snake_Cur_X > 10)                           If greater
     C                   Z-Add     1             Snake_Cur_X                    .Then resize
     C                   EndIf
     C                   When      (Snake_Heading = 'W')                        Move West
     C                   Sub       1             Snake_Cur_Y
     C                   If        (Snake_Cur_Y < 1)                            If greater
     C                   Z-Add     50            Snake_Cur_Y                    .Then resize
     C                   EndIf
     C                   When      (Snake_Heading = 'E')                        Move East
     C                   Add       1             Snake_Cur_Y
     C                   If        (Snake_Cur_Y > 50)                           If greater
     C                   Z-Add     1             Snake_Cur_Y                    .Then resize
     C                   EndIf
     C                   EndSl
      *
      * Clear the previous buffer
     C                   Clear                   SnakePos_Char
     C                   ExSr      SrPlaceFood
      *
      * Get current position
      *                  Move the body only
     C                   If        (Snake_Grow > *Zeros)
     C                   If        (Add_To_Tail = (Snake_Length-1))
     C                   Z-Add     *Zeros        Add_To_Tail
     C                   Eval      Snake_Prev_X(Snake_Length+1) =
     C                             Snake_Prev_X(Snake_Length)
     C                   Eval      Snake_Prev_Y(Snake_Length+1) =
     C                             Snake_Prev_Y(Snake_Length)
     C                   Eval      Result = (50 * (Snake_Prev_X(Snake_Length+1)
     C                                      - 1) + Snake_Prev_Y(Snake_Length+1))
     C                   Eval      SnakePos_Arr(Result) = ('o')
     C                   Else
     C                   Add       1             Add_To_Tail
     C                   EndIf
     C                   EndIf
     C                   For       Snake_Prev_Cnt = Snake_Length DownTo 2
     C                   Eval      Snake_Prev_X(Snake_Prev_Cnt) =
     C                             Snake_Prev_X(Snake_Prev_Cnt-1)
     C                   Eval      Snake_Prev_Y(Snake_Prev_Cnt) =
     C                             Snake_Prev_Y(Snake_Prev_Cnt-1)
     C                   Eval      Result = (50 * (Snake_Prev_X(Snake_Prev_Cnt)
     C                                      - 1) + Snake_Prev_Y(Snake_Prev_Cnt))
     C                   Eval      SnakePos_Arr(Result) = ('o')
     C                   EndFor
     C                   If        (Snake_Grow > *Zeros) And
     C                             (Add_To_Tail = *Zeros)
     C                   Sub       1             Snake_Grow
     C                   Add       1             Snake_Length
     C                   If        (Snake_Grow > *Zeros)
     C                   Add       1             Add_To_Tail
     C                   EndIf
     C                   EndIf
      *
      *                  Move head
     C                   Eval      Snake_Prev_X(1) = (Snake_Cur_X)
     C                   Eval      Snake_Prev_Y(1) = (Snake_Cur_Y)
     C                   Eval      Result = (50 * (Snake_Prev_X(1) - 1) +
     C                                       Snake_Prev_Y(1))
     C                   If        (SnakePos_Arr(Result) <> (*Blanks))
     C                   ExSr      SrBlockUsed
     C                   EndIf
     C                   If        (Ind_EndGame = *On)
     C                   Movel(P)  'GAME OVER'   WStatus
     C                   LeaveSr
     C                   EndIf
     C                   Eval      SnakePos_Arr(Result) = ('$')
      *
      * Place food block
     C                   ExSr      SrPlaceFood
      *
     C                   EndSr
      *
      *------------------------------------------------------------------------------------------
      * SrAutoMov2 Sub Routine
      *  Automatically move the snake forward
      *------------------------------------------------------------------------------------------
      *
     C     SrAutoMov2    BegSr
      *
     C                   Eval      Snak2_Cur_X = (Snak2_Prev_X(1))              Get head X position
     C                   Eval      Snak2_Cur_Y = (Snak2_Prev_Y(1))              Get head Y position
      *
      * Find out where to move next
     C                   Eval      Snake_Food_X = Snake_Food / 50
     C                   Eval      Snake_Food_Y = %Rem(Snake_Food:50)
      *
     C                   If        ((Snak2_Cur_X - 1) = Snake_Food_X)
     C                   If        (Snak2_Cur_Y < Snake_Food_Y)
     C                   Movel(P)  'E'           Snak2_Heading
     C                   ElseIf    (Snak2_Cur_Y > Snake_Food_Y)
     C                   Movel(P)  'W'           Snak2_Heading
     C                   EndIf
      *
     C                   ElseIf    (Snak2_Cur_Y = Snake_Food_Y)
     C                   If        ((Snak2_Cur_X - 1) < Snake_Food_X)
     C                   Movel(P)  'S'           Snak2_Heading
     C                   ElseIf    ((Snak2_Cur_X - 1) > Snake_Food_X)
     C                   Movel(P)  'N'           Snak2_Heading
     C                   EndIf
     C                   EndIf
      *
     C                   Select
     C                   When      (Snak2_Heading = 'N')                        Move North
     C                   Sub       1             Snak2_Cur_X
     C                   If        (Snak2_Cur_X < 1)                            If greater
     C                   Z-Add     10            Snak2_Cur_X                    .Then resize
     C                   EndIf
     C                   When      (Snak2_Heading = 'S')                        Move South
     C                   Add       1             Snak2_Cur_X
     C                   If        (Snak2_Cur_X > 10)                           If greater
     C                   Z-Add     1             Snak2_Cur_X                    .Then resize
     C                   EndIf
     C                   When      (Snak2_Heading = 'W')                        Move West
     C                   Sub       1             Snak2_Cur_Y
     C                   If        (Snak2_Cur_Y < 1)                            If greater
     C                   Z-Add     50            Snak2_Cur_Y                    .Then resize
     C                   EndIf
     C                   When      (Snak2_Heading = 'E')                        Move East
     C                   Add       1             Snak2_Cur_Y
     C                   If        (Snak2_Cur_Y > 50)                           If greater
     C                   Z-Add     1             Snak2_Cur_Y                    .Then resize
     C                   EndIf
     C                   EndSl
      *
      * Get current position
      *                  Move the body only
     C                   If        (Snak2_Grow > *Zeros)
     C                   If        (Add_To_Tail = (Snak2_Length-1))
     C                   Z-Add     *Zeros        Add_To_Tail
     C                   Eval      Snak2_Prev_X(Snak2_Length+1) =
     C                             Snak2_Prev_X(Snak2_Length)
     C                   Eval      Snak2_Prev_Y(Snak2_Length+1) =
     C                             Snak2_Prev_Y(Snak2_Length)
     C                   Eval      Result = (50 * (Snak2_Prev_X(Snak2_Length+1)
     C                                      - 1) + Snak2_Prev_Y(Snak2_Length+1))
     C                   Eval      SnakePos_Arr(Result) = ('x')
     C                   Else
     C                   Add       1             Add_To_Tail
     C                   EndIf
     C                   EndIf
     C                   For       Snak2_Prev_Cnt = Snak2_Length DownTo 2
     C                   Eval      Snak2_Prev_X(Snak2_Prev_Cnt) =
     C                             Snak2_Prev_X(Snak2_Prev_Cnt-1)
     C                   Eval      Snak2_Prev_Y(Snak2_Prev_Cnt) =
     C                             Snak2_Prev_Y(Snak2_Prev_Cnt-1)
     C                   Eval      Result = (50 * (Snak2_Prev_X(Snak2_Prev_Cnt)
     C                                      - 1) + Snak2_Prev_Y(Snak2_Prev_Cnt))
     C                   Eval      SnakePos_Arr(Result) = ('x')
     C                   EndFor
     C                   If        (Snak2_Grow > *Zeros) And
     C                             (Add_To_Tail = *Zeros)
     C                   Sub       1             Snak2_Grow
     C                   Add       1             Snak2_Length
     C                   If        (Snak2_Grow > *Zeros)
     C                   Add       1             Add_To_Tail
     C                   EndIf
     C                   EndIf
      *
      *                  Move head
     C                   Eval      Snak2_Prev_X(1) = (Snak2_Cur_X)
     C                   Eval      Snak2_Prev_Y(1) = (Snak2_Cur_Y)
     C                   Eval      Result = (50 * (Snak2_Prev_X(1) - 1) +
     C                                       Snak2_Prev_Y(1))
     C                   If        (SnakePos_Arr(Result) <> (*Blanks))
     C                   ExSr      SrBlockUse2
     C                   EndIf
     C                   If        (Ind_EndGame = *On)
     C                   Movel(P)  'GAME OVER'   WStatus
     C                   LeaveSr
     C                   EndIf
     C                   Eval      SnakePos_Arr(Result) = ('@')
      *
     C                   EndSr
      *
      *------------------------------------------------------------------------------------------
      * SrBlockUsed Sub Routine
      *  Check if the block is already occupied
      *------------------------------------------------------------------------------------------
      *
     C     SrBlockUsed   BegSr
      *
     C                   Select
      *
      * Economy Class points
     C                   When      (SnakePos_Arr(Result) = 'Y')
     C                   Add       1             User_Score                     1 point
     C                   Add       1             Snake_Grow                     Add snake size
     C                   ExSr      SrRand
      *
      * Raffles Class or Business Class points
     C                   When      (SnakePos_Arr(Result) = 'C')
     C                   Add       8             User_Score                     8 points
     C                   Add       1             Snake_Grow                     Add snake size
     C                   ExSr      SrRand
      *
      * First Class points
     C                   When      (SnakePos_Arr(Result) = 'F')
     C                   Add       10            User_Score                     10 points
     C                   Add       1             Snake_Grow                     Add snake size
     C                   ExSr      SrRand
      *
      * The snake ran into itself, game over!
     C                   Other
     C                   Move      *On           Ind_EndGame                    Game over
      *
     C                   EndSl
      *
     C                   EndSr
      *
      *------------------------------------------------------------------------------------------
      * SrBlockUse2 Sub Routine
      *  Check if the block is already occupied
      *------------------------------------------------------------------------------------------
      *
     C     SrBlockUse2   BegSr
      *
     C                   Select
      *
      * Economy Class points
     C                   When      (SnakePos_Arr(Result) = 'Y')
     C                   Add       1             Comp_Score                     1 point
     C                   Add       1             Snak2_Grow                     Add snake size
     C                   ExSr      SrRand
      *
      * Raffles Class or Business Class points
     C                   When      (SnakePos_Arr(Result) = 'C')
     C                   Add       8             Comp_Score                     8 points
     C                   Add       1             Snak2_Grow                     Add snake size
     C                   ExSr      SrRand
      *
      * First Class points
     C                   When      (SnakePos_Arr(Result) = 'F')
     C                   Add       10            Comp_Score                     10 points
     C                   Add       1             Snak2_Grow                     Add snake size
     C                   ExSr      SrRand
      *
      * The snake ran into itself, game over!
     C                   Other
     C                   Move      *On           Ind_EndGame                    Game over
      *
     C                   EndSl
      *
     C                   EndSr
      *
      *------------------------------------------------------------------------------------------
      * SrPutToScreen Sub Routine
      *  Move program data to display
      *------------------------------------------------------------------------------------------
      *
     C     SrPutToScreen BegSr
      *
      * Move the block elements
     C                   Eval      WLine01 = (%Subst(SnakePos_Char:001:50))     X=01, Y=001 to Y=050
     C                   Eval      WLine02 = (%Subst(SnakePos_Char:051:50))     X=02, Y=051 to Y=100
     C                   Eval      WLine03 = (%Subst(SnakePos_Char:101:50))     X=03, Y=101 to Y=150
     C                   Eval      WLine04 = (%Subst(SnakePos_Char:151:50))     X=04, Y=151 to Y=200
     C                   Eval      WLine05 = (%Subst(SnakePos_Char:201:50))     X=05, Y=201 to Y=250
     C                   Eval      WLine06 = (%Subst(SnakePos_Char:251:50))     X=06, Y=251 to Y=300
     C                   Eval      WLine07 = (%Subst(SnakePos_Char:301:50))     X=07, Y=301 to Y=350
     C                   Eval      WLine08 = (%Subst(SnakePos_Char:351:50))     X=08, Y=351 to Y=400
     C                   Eval      WLine09 = (%Subst(SnakePos_Char:401:50))     X=09, Y=401 to Y=450
     C                   Eval      WLine10 = (%Subst(SnakePos_Char:451:50))     X=10, Y=451 to Y=500
      *
      * Move score information
     C                   Z-Add     User_Score    WScore
     C                   Z-Add     Comp_Score    WScor2
     C                   Z-Add     Snake_Length  WLength
     C                   Z-Add     Snak2_Length  WLengt2
      *
     C                   EndSr
      *
      *------------------------------------------------------------------------------------------
      * SrRand Sub Routine
      *  Generate random number using ILE C function
      *------------------------------------------------------------------------------------------
      *
     C     SrRand        BegSr
      *
     C                   Z-Add     *Zeros        Snake_Food                     Set to zeros
      *
     C     #SrRand_Again Tag
     C                   Eval      Temp_Rand = (GetRandom)                      Use procedure
     C                   If        (Temp_Rand > 1001)                           If too big
     C     Temp_Rand     Div       50            Temp_Rand                      .Then divide
     C                   EndIf
     C                   If        (Temp_Rand > 500)                            If > 500
     C                   DoW       (Temp_Rand > 500)                            .Then do until
     C                   Sub       500           Temp_Rand                       value is less
     C                   EndDo
     C                   EndIf
      *
     C                   If        SnakePos_Arr(Temp_Rand) = (*Blanks)          If block available
     C                   Z-Add     Temp_Rand     Snake_Food                     .Then allocate
     C                   EndIf
      *
     C                   If        (Snake_Food = *Zeros)                        If value not ok
     C                   Goto      #SrRand_Again                                .Then try again
     C                   EndIf
      *
     C                   EndSr
      *
      *------------------------------------------------------------------------------------------
      * SrPlaceFood Sub Routine
      *  Place food for snake
      *------------------------------------------------------------------------------------------
      *
     C     SrPlaceFood   BegSr
      *
     C                   Select
      *
      * First Class meals = 10 points
      * (You've got to fly Singapore Airlines to know what I mean!)
     C                   When      (Snake_Food = 123) Or
     C                             (Snake_Food = 456) Or
     C                             (Snake_Food = 321) Or
     C                             (Snake_Food = 497) Or
     C                             (Snake_Food = 135) Or
     C                             (Snake_Food = 498) Or
     C                             (Snake_Food = 246) Or
     C                             (Snake_Food = 155) Or
     C                             (Snake_Food = 255) Or
     C                             (Snake_Food = 355) Or
     C                             (Snake_Food = 455) Or
     C                             (Snake_Food = 122) Or
     C                             (Snake_Food = 322) Or
     C                             (Snake_Food = 331)
     C                   Eval      SnakePos_Arr(Snake_Food) = ('F')
      *
      * Raffles Class or Business Class meals = 5 points
      * (You've got to fly Singapore Airlines to know what I mean!)
     C                   When      (Snake_Food = 011) Or
     C                             (Snake_Food = 022) Or
     C                             (Snake_Food = 033) Or
     C                             (Snake_Food = 044) Or
     C                             (Snake_Food = 055) Or
     C                             (Snake_Food = 066) Or
     C                             (Snake_Food = 077) Or
     C                             (Snake_Food = 088) Or
     C                             (Snake_Food = 099) Or
     C                             (Snake_Food = 111) Or
     C                             (Snake_Food = 222) Or
     C                             (Snake_Food = 333) Or
     C                             (Snake_Food = 444) Or
     C                             (Snake_Food = 499)
     C                   Eval      SnakePos_Arr(Snake_Food) = ('C')
      *
      * Economy Class meals = 1 point
     C                   Other
     C                   Eval      SnakePos_Arr(Snake_Food) = ('Y')
      *
     C                   EndSl
      *
     C                   EndSr
      *
      *------------------------------------------------------------------------------------------
      * SrInit Sub Routine
      *  Program initialize routine
      *------------------------------------------------------------------------------------------
      *
     C     SrInit        BegSr
      *
      * Initialize snake length
     C                   Z-Add     2             Snake_Length
     C                   Z-Add     2             Snak2_Length
      *
      * Initialize snake position
      *                  Get head
     C                   Z-Add     5             Pos_X
     C                   Z-Add     25            Pos_Y
     C                   Eval      Result = (50 * (Pos_X - 1) + Pos_Y)
     C                   Eval      SnakePos_Arr(Result) = ('$')
      *                  Get body
     C                   Z-Add     6             Pos_X
     C                   Z-Add     25            Pos_Y
     C                   Eval      Result = (50 * (Pos_X - 1) + Pos_Y)
     C                   Eval      SnakePos_Arr(Result) = ('o')
      *
      *                  Get head
     C                   Z-Add     3             Pos_X
     C                   Z-Add     23            Pos_Y
     C                   Eval      Result = (50 * (Pos_X - 1) + Pos_Y)
     C                   Eval      SnakePos_Arr(Result) = ('@')
      *                  Get body
     C                   Z-Add     2             Pos_X
     C                   Z-Add     23            Pos_Y
     C                   Eval      Result = (50 * (Pos_X - 1) + Pos_Y)
     C                   Eval      SnakePos_Arr(Result) = ('x')
      *
      * Initialize snake path
     C                   Movel(P)  'N'           Snake_Heading
     C                   Eval      Snake_Prev_X(1) = 5
     C                   Eval      Snake_Prev_Y(1) = 25
     C                   Eval      Snake_Prev_X(2) = 6
     C                   Eval      Snake_Prev_Y(2) = 25
      *
     C                   Movel(P)  'S'           Snak2_Heading
     C                   Eval      Snak2_Prev_X(1) = 3
     C                   Eval      Snak2_Prev_Y(1) = 23
     C                   Eval      Snak2_Prev_X(2) = 2
     C                   Eval      Snak2_Prev_Y(2) = 23
      *
      * Get time
     C                   Time                    Time_LstMove
      *
      * Get food block
     C                   ExSr      SrRand
     C                   ExSr      SrPlaceFood
      *
     C                   EndSr
      *
