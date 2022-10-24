//program is not stable //<>// //<>//
//error handling is not enough, error codes and exit codes havent been created yet

int sqSize=70;
int canvasSize=600;
int offsetVal=(canvasSize-8*sqSize)/2; //offset for the board
int offsetValImage=(canvasSize-500)/2; //offset for failed and passed images
int offsetValSq=(sqSize-50)/2+offsetVal; //offset for knight piece images
int[] sqColors=new int[64];
boolean isPassed, isFailed;
PImage black, white, failed, passed;
String moves;
int moveNum;
ArrayList<Integer> moveSq;
boolean doesShowRoute=true, doesEmphasizeClickedSquare=true;
float buttonW=150, buttonH=100, buttonX=625, buttonYStartPos=offsetVal, buttonYoffset=10;
PrintWriter output;
boolean restrictBoardClicks;
String filePath="ExportedGames/";
void setup() {
  size(800, 600);
  background(100);
  for (int i=0; i<sqColors.length; i++) {
    sqColors[i]=0;
  }
  isFailed=false;
  isPassed=false;
  moves="";
  moveNum=0;
  moveSq=new ArrayList<>(0);
  initializeBoard();
  initializeButtons();
  println("initialized");
  white = loadImage("source/knight_03_black.png");  //50x50
  black = loadImage("source/knight_03_white.png");  //50x50
  passed = loadImage("source/passed.png");          //500x500
  failed = loadImage("source/failed_02.png");       //500x275

  restrictBoardClicks=false;
}
void draw() {
  initializeBoard();
  initializeButtons();
  updateBoard();
  if (doesShowRoute) updateRoute();
  renderStatusImage();
}
int mx, my, posX, posY;
void mouseClicked() {
  if (mouseX>offsetVal&&mouseX<offsetVal+8*sqSize&&mouseY>offsetVal&&mouseY<offsetVal+8*sqSize && !restrictBoardClicks) {
    if (mouseButton==LEFT) {
      mx=(mouseX-offsetVal)/sqSize;
      posX=1+mx;
      my=(mouseY-offsetVal)/sqSize;
      posY=8-my;
      if (index2str(mx, my).equals("Warning: User clicked outside of the board")) {
      } else {
        moveSq.add(mx);
        moveSq.add(my);
        if (sqColors[mx*8+my]==2) {
          sqColors[mx*8+my]=1;
        } else if (sqColors[mx*8+my]==1) {
          println("Challange Failed!\nThis square is already clicked!");
          isFailed=true;
          takeBackLastMove();
          renderStatusImage();
        } else if (moveNum==0&&sqColors[mx*8+my]==0) {
          sqColors[mx*8+my]=1;
        } else if (moveNum!=0&&sqColors[mx*8+my]==0) {
          println("Illegal move, try another move");
          takeBackLastMove();
        } else {
          println("Error: [MouseClicked]");
        }
        moveNum++;
        moves+=moveNum+".N"+index2str(mx, my)+" ";
      }
      checkPossibleSquares(posX, posY);
      if (checkPossibleSquares(posX, posY)==0&&isPassed==false) isFailed=true;
    } else if (mouseButton==RIGHT&&doesEmphasizeClickedSquare) {
      mx=(mouseX-offsetVal)/sqSize;
      posX=1+mx;
      my=(mouseY-offsetVal)/sqSize;
      posY=8-my;
      switch(sqColors[mx*8+my]) {
      case 0:
        sqColors[mx*8+my]=4;
        break;
      case 1:
        sqColors[mx*8+my]=5;
        break;
      case 2:
        sqColors[mx*8+my]=6;
        break;
      case 3:
        break;
      case 4:
        sqColors[mx*8+my]=0;
        break;
      case 5:
        sqColors[mx*8+my]=1;
        break;
      case 6:
        sqColors[mx*8+my]=2;
        break;
      default:
        break;
      }
    } else if (mouseButton==CENTER&&doesEmphasizeClickedSquare) {
      for (int i=0; i<sqColors.length; i++) {
        switch(sqColors[i]) {
        case 4:
          sqColors[i]=0;
          break;
        case 5:
          sqColors[i]=1;
          break;
        case 6:
          sqColors[i]=2;
          break;
        default:
          break;
        }
      }
    }
  } else if (mouseX>buttonX&&mouseX<buttonX+buttonW) {
    if (mouseY>buttonYStartPos+(buttonH+buttonYoffset)*0&&mouseY<buttonYStartPos+(buttonH+buttonYoffset)*0+buttonH) {
      println("Exit code: User triggered exit button");
      exit();
    } else if (mouseY>buttonYStartPos+(buttonH+buttonYoffset)*1&&mouseY<buttonYStartPos+(buttonH+buttonYoffset)*1+buttonH) {
      setup();
    } else if (mouseY>buttonYStartPos+(buttonH+buttonYoffset)*2&&mouseY<buttonYStartPos+(buttonH+buttonYoffset)*2+buttonH) {
      if (doesShowRoute) {
        doesShowRoute=false;
      } else {
        doesShowRoute=true;
      }
    } else if (mouseY>buttonYStartPos+(buttonH+buttonYoffset)*3&&mouseY<buttonYStartPos+(buttonH+buttonYoffset)*3+buttonH) {
      if (doesEmphasizeClickedSquare) {
        doesEmphasizeClickedSquare=false;
      } else {
        doesEmphasizeClickedSquare=true;
      }
    } else if (mouseY>buttonYStartPos+(buttonH+buttonYoffset)*4&&mouseY<buttonYStartPos+(buttonH+buttonYoffset)*4+buttonH) {
      if (mouseButton==RIGHT) {
        selectFolder("Select a folder to process.", "folderSelected");
      } else if (mouseButton==LEFT) {
        String fileName=filePath+""+year()+(month()<10?"0":"")+month()+(day()<10?"0":"")+day()+"_"+(hour()<10?"0":"")+hour()+(minute()<10?"0":"")+minute()+"_"+(second()<10?"0":"")+second()+"_knight_challange.txt";
        output=createWriter(fileName);
        String chalStat;
        if (isPassed) {
          chalStat="Succesful";
        } else if (isFailed) {
          chalStat="Unsuccesful";
        } else {
          chalStat="Unfinished";
        }
        String fen="";
        int firstPosX=1+moveSq.get(0);
        int firstPosY=8-moveSq.get(1);
        for (int j=1; j<=8; j++) {
          if (j==firstPosY) {
            fen=(firstPosX-1==0?"":firstPosX-1)+((firstPosX+firstPosY)%2==0?"N":"n")+(8-firstPosX==0?"":8-firstPosX)+fen;
          } else {
            fen="8"+fen;
          }
          fen=(j==8?"":"/")+fen;
        }
        output.println("Date: "+(day()<10?"0":"")+day()+"."+(month()<10?"0":"")+month()+"."+year()+" "+(hour()<10?"0":"")+hour()+":"+(minute()<10?"0":"")+minute()+":"+(second()<10?"0":"")+second());
        output.println("Challange status:"+chalStat);
        output.println("Starting position in FEN format;");
        output.println("FEN:"+fen);
        output.println("Moves:");
        output.println(moves);
        output.flush();
        output.close();
        println("Game has been exported: "+fileName);
      } else {
      }
    }
  }
}
void updateBoard() {
  int offset=5;// offset for emphesizing colored rectangles
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {
      switch(sqColors[i*8+j]) {
      case 0: //in case of a square that has not been clicked
        if ((i+j)%2==0) {
          fill(255);//white
        } else {
          fill(0);//black
        }
        rect(offsetVal+i*sqSize, offsetVal+j*sqSize, sqSize, sqSize);
        break;
      case 1: //in case of a square that has already been clicked
        if (doesEmphasizeClickedSquare) {
          fill(186, 186, 22);//yellow~green
        } else {
          if ((i+j)%2==0) {
            fill(255);//white
          } else {
            fill(0);//black
          }
        }
        rect(offsetVal+i*sqSize+offset, offsetVal+j*sqSize+offset, sqSize-offset*2, sqSize-offset*2);
        if ((i+j)%2==0) {
          image(white, offsetValSq+i*sqSize, offsetValSq+j*sqSize);
        } else {
          image(black, offsetValSq+i*sqSize, offsetValSq+j*sqSize);
        }
        break;
      case 2: //in case of a square that user can move to
        if (doesEmphasizeClickedSquare) {
          fill(31, 145, 130);//green for available squares
          rect(offsetVal+i*sqSize+offset, offsetVal+j*sqSize+offset, sqSize-offset*2, sqSize-offset*2);
        }
        break;
      case 4: //for user-interaction only
        if (doesEmphasizeClickedSquare) {
          fill(255, 99, 71);//tomato color for right click (hex code:#ff6347)
          rect(offsetVal+i*sqSize+offset, offsetVal+j*sqSize+offset, sqSize-offset*2, sqSize-offset*2);
        }
        break;
      case 5:
        if (doesEmphasizeClickedSquare) {
          fill(255, 99, 71);//tomato color for right click (hex code:#ff6347)
          rect(offsetVal+i*sqSize+offset, offsetVal+j*sqSize+offset, sqSize-offset*2, sqSize-offset*2);
        }
        break;
      case 6:
        if (doesEmphasizeClickedSquare) {
          fill(255, 99, 71);//tomato color for right click (hex code:#ff6347)
          rect(offsetVal+i*sqSize+offset, offsetVal+j*sqSize+offset, sqSize-offset*2, sqSize-offset*2);
        }
        break;
      default:
        fill(255, 0, 0);//red
        rect(offsetVal+i*sqSize, offsetVal+j*sqSize, sqSize, sqSize);
      }
    }
  }
}
void initializeBoard() {
  for (int i=0; i<8; i++) {
    for (int j=0; j<8; j++) {
      if ((i+j)%2==0) {
        fill(255);
      } else {
        fill(0);
      }
      rect(offsetVal+i*sqSize, offsetVal+j*sqSize, sqSize, sqSize);
    }
  }
}

//void sqColorTable() { //prints SqColor table in console
//  for (int i=0; i<8; i++) {
//    print("|");
//    for (int j=0; j<8; j++) {
//      print(sqColors[i+8*j]);
//      print("|");
//    }
//    println();
//  }
//}

String index2str(int x, int y) {
  String str;
  if (y<0||y>8) {
    return "Warning: User clicked outside of the board";
  } else {
    str=""+(8-y);
  }
  switch(x) {
  case 0:
    str="a"+str;
    break;
  case 1:
    str="b"+str;
    break;
  case 2:
    str="c"+str;
    break;
  case 3:
    str="d"+str;
    break;
  case 4:
    str="e"+str;
    break;
  case 5:
    str="f"+str;
    break;
  case 6:
    str="g"+str;
    break;
  case 7:
    str="h"+str;
    break;
  default:
    return "Warning: User clicked outside of the board";
  }

  return str;
}
void renderStatusImage() {
  if (isPassed) {
    image(passed, offsetValImage, offsetValImage);
    restrictBoardClicks=true;
  }
  if (isFailed&&!isPassed) {
    image(failed, offsetValImage, offsetValImage);
    restrictBoardClicks=true;
  }
}
void updateRoute() {
  if (moveNum<2) {
  } else if (moveNum>=2 ) {
    stroke(187, 61, 212);
    strokeWeight(6);
    for (int lineIndex=0; lineIndex<moveNum-1; lineIndex++) {
      line(sq2float(moveSq.get(lineIndex*2)), sq2float(moveSq.get(lineIndex*2+1)), sq2float(moveSq.get(lineIndex*2+2)), sq2float(moveSq.get(lineIndex*2+3)));
    }
  } else {
    println("Error: [updateRoute]");
  }
  noStroke();
}
float sq2float(int sq) {
  return offsetVal+sq*sqSize+sqSize/2;
}
void printAL() {
  print("\nsize:"+moveSq.size()+"\n");
  for (int i=0; i<moveSq.size(); i++) {
    print(i+"\t");
  }
  println();
  for (int i=0; i<moveSq.size(); i++) {
    print(moveSq.get(i)+"\t");
  }
  println();
}
int getClickedXOnBoard(float x) {
  int i=0;
  i=(int) (x-offsetVal)/sqSize;
  return i;
}
void initializeButtons() {
  fill(24, 39, 46); //button color
  stroke(0);
  rect(buttonX, buttonYStartPos+(buttonH+buttonYoffset)*0, buttonW, buttonH);//exit
  rect(buttonX, buttonYStartPos+(buttonH+buttonYoffset)*1, buttonW, buttonH);//New Game
  rect(buttonX, buttonYStartPos+(buttonH+buttonYoffset)*2, buttonW, buttonH);//show route
  rect(buttonX, buttonYStartPos+(buttonH+buttonYoffset)*3, buttonW, buttonH);//emphasize clicked squares
  rect(buttonX, buttonYStartPos+(buttonH+buttonYoffset)*4, buttonW, buttonH);//export moves
  textSize(18);
  fill(255);
  noStroke();
  textAlign(CENTER, CENTER);
  text("EXIT \n(X)", buttonX, buttonYStartPos+(buttonH+buttonYoffset)*0, buttonW, buttonH);//exit
  text("NEW GAME", buttonX, buttonYStartPos+(buttonH+buttonYoffset)*1, buttonW, buttonH);
  text("SHOW KNIGHT'S ROUTE\n"+(doesShowRoute?"ON":"OFF"), buttonX, buttonYStartPos+(buttonH+buttonYoffset)*2, buttonW, buttonH);
  text("EMPHASIZE CLICKED SQUARES\n"+(doesEmphasizeClickedSquare?"ON":"OFF"), buttonX, buttonYStartPos+(buttonH+buttonYoffset)*3, buttonW, buttonH);
  text("EXPORT MOVES\n[Right Click to Set Export Directory]", buttonX, buttonYStartPos+(buttonH+buttonYoffset)*4, buttonW, buttonH);
}
int checkPossibleSquares(int x, int y) {
  changePossibleSquaresBack();
  boolean isPSQ=false;
  int numOfPSQ=0;
  if (x+2<=8&&y+1<=8) {
    if (sqColors[(x+2-1)*8+(8-y-1)]==0) {
      sqColors[(x+2-1)*8+(8-y-1)]=2;
      isPSQ=true;
      numOfPSQ++;
    }
  }
  if (x+2<=8&&y-1>=1) {
    if (sqColors[(x-1+2)*8+(8-y+1)]==0) {
      sqColors[(x-1+2)*8+(8-y+1)]=2;
      isPSQ=true;
      numOfPSQ++;
    }
  }
  if (x+1<=8&&y+2<=8) {
    if (sqColors[(x-1+1)*8+(8-y-2)]==0) {
      sqColors[(x)*8+(8-y)-2]=2;
      isPSQ=true;
      numOfPSQ++;
    }
  }
  if (x+1<=8&&y-2>=1) {
    if (sqColors[(x)*8+(8-y+2)]==0) {
      sqColors[(x)*8+(8-y+2)]=2;
      isPSQ=true;
      numOfPSQ++;
    }
  }
  if (x-1>=1&&y+2<=8) {
    if (sqColors[(x-1-1)*8+(8-y-2)]==0) {
      sqColors[(x-1-1)*8+(8-y-2)]=2;
      isPSQ=true;
      numOfPSQ++;
    }
  }
  if (x-1>=1&&y-2>=1) {
    if (sqColors[(x-1-1)*8+(8-y+2)]==0) {
      sqColors[(x-1-1)*8+(8-y+2)]=2;
      isPSQ=true;
      numOfPSQ++;
    }
  }
  if (x-2>=1&&y+1<=8) {
    if (sqColors[(x-1-2)*8+(8-y-1)]==0) {
      sqColors[(x-1-2)*8+(8-y-1)]=2;
      isPSQ=true;
      numOfPSQ++;
    }
  }
  if (x-2>=1&&y-1>=1) {
    if (sqColors[(x-1-2)*8+(8-y+1)]==0) {
      sqColors[(x-1-2)*8+(8-y+1)]=2;
      isPSQ=true;
      numOfPSQ++;
    }
  }
  if (!isPSQ && isPassed) {
    isFailed=true;
  } else {
    isPassed=true;
    for (int i=0; i<sqColors.length; i++) {
      if (sqColors[i]!=1) isPassed=false;
    }
  }
  return numOfPSQ;
}
void changePossibleSquaresBack() {
  for (int i=0; i<sqColors.length; i++) {
    if (sqColors[i]==2) {
      sqColors[i]=0;
    }
  }
}
void takeBackLastMove() {
  moveSq.remove(moveSq.size()-1);//this line removes last added mouseY
  moveSq.remove(moveSq.size()-1);//when mouseY is removed last item is mouse X
  moveNum--;
  mx=moveSq.get(moveSq.size()-2);
  my=moveSq.get(moveSq.size()-1);
  posX=1+mx;
  posY=8-my;
}
void folderSelected(File selection) {
  if (selection == null) {
    println("Folder selection window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    filePath=selection.getAbsolutePath();
  }
}
