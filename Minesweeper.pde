import de.bezier.guido.*;

private static final int NUM_ROWS  = 20;
private static final int NUM_COLS  = 20;
private static final int NUM_MINES = 40;

private MSButton[][] buttons;
private ArrayList<MSButton> mines;
private boolean gameOver    = false;
private boolean firstClick  = true;

void setup()
{
    size(400, 400);
    textAlign(CENTER, CENTER);
    Interactive.make(this);
    buttons = new MSButton[NUM_ROWS][NUM_COLS];
    mines   = new ArrayList<MSButton>();
    for (int r = 0; r < NUM_ROWS; r++)
        for (int c = 0; c < NUM_COLS; c++)
            buttons[r][c] = new MSButton(r, c);
}

public void setMines(int safeRow, int safeCol)
{
    mines.clear();
    while (mines.size() < NUM_MINES) {
        int r = (int)(Math.random() * NUM_ROWS);
        int c = (int)(Math.random() * NUM_COLS);
        if (Math.abs(r - safeRow) <= 1 && Math.abs(c - safeCol) <= 1) continue;
        if (!mines.contains(buttons[r][c]))
            mines.add(buttons[r][c]);
    }
}

public void draw()
{
    background(0);
    for (int r = 0; r < NUM_ROWS; r++)
        for (int c = 0; c < NUM_COLS; c++)
            buttons[r][c].draw();
    if (!gameOver && !firstClick && isWon())
        displayWinningMessage();
}

public boolean isWon()
{
    for (int r = 0; r < NUM_ROWS; r++)
        for (int c = 0; c < NUM_COLS; c++)
            if (!mines.contains(buttons[r][c]) && !buttons[r][c].clicked)
                return false;
    return true;
}

public void displayLosingMessage()
{
    gameOver = true;
    for (MSButton m : mines) { m.clicked = true; m.setLabel("*"); }
    String msg = "GAME OVER";
    int midRow = NUM_ROWS / 2, startCol = (NUM_COLS - msg.length()) / 2;
    for (int i = 0; i < msg.length(); i++)
        if (isValid(midRow, startCol + i))
            buttons[midRow][startCol + i].setLabel(String.valueOf(msg.charAt(i)));
}

public void displayWinningMessage()
{
    gameOver = true;
    String msg = "YOU  WON!";
    int midRow = NUM_ROWS / 2, startCol = (NUM_COLS - msg.length()) / 2;
    for (int i = 0; i < msg.length(); i++)
        if (isValid(midRow, startCol + i))
            buttons[midRow][startCol + i].setLabel(String.valueOf(msg.charAt(i)));
}

public boolean isValid(int r, int c)
{
    return r >= 0 && r < NUM_ROWS && c >= 0 && c < NUM_COLS;
}

public int countMines(int row, int col)
{
    int numMines = 0;
    for (int dr = -1; dr <= 1; dr++)
        for (int dc = -1; dc <= 1; dc++) {
            if (dr == 0 && dc == 0) continue;
            int nr = row + dr, nc = col + dc;
            if (isValid(nr, nc) && mines.contains(buttons[nr][nc])) numMines++;
        }
    return numMines;
}

void keyPressed()
{
    if (key == 'r' || key == 'R') {
        mines.clear();
        gameOver = false;
        firstClick = true;
        for (int r = 0; r < NUM_ROWS; r++)
            for (int c = 0; c < NUM_COLS; c++) {
                buttons[r][c].clicked = false;
                buttons[r][c].flagged = false;
                buttons[r][c].setLabel("");
            }
    }
}

public class MSButton
{
    private int    myRow, myCol;
    public float   x, y, width, height;
    public boolean clicked, flagged;
    private String myLabel;

    public MSButton(int row, int col)
    {
        myRow = row; myCol = col;
        myLabel = "";
        flagged = clicked = false;
        Interactive.add(this);
        width  = 400.0 / NUM_COLS;
        height = 400.0 / NUM_ROWS;
        x = myCol * width;
        y = myRow * height;
    }

    public void mousePressed()
    {
        if (gameOver) return;
        if (mouseButton == RIGHT) { if (!clicked) flagged = !flagged; return; }
        if (clicked || flagged) return;
        if (firstClick) { setMines(myRow, myCol); firstClick = false; }
        clicked = true;
        if (mines.contains(this)) {
            displayLosingMessage();
        } else {
            int nearby = countMines(myRow, myCol);
            if (nearby > 0) {
                setLabel(nearby);
            } else {
                for (int dr = -1; dr <= 1; dr++)
                    for (int dc = -1; dc <= 1; dc++) {
                        if (dr == 0 && dc == 0) continue;
                        int nr = myRow + dr, nc = myCol + dc;
                        if (isValid(nr, nc) && !buttons[nr][nc].clicked && !buttons[nr][nc].flagged)
                            buttons[nr][nc].mousePressed();
                    }
            }
        }
    }

    public void draw()
    {
        strokeWeight(1); stroke(50);
        if      (flagged && !clicked)          fill(255, 200, 0);
        else if (clicked && mines.contains(this)) fill(255, 0, 0);
        else if (clicked)                      fill(200);
        else                                   fill(100);
        rect(x, y, width, height);
        if (flagged && !clicked) { fill(0); text("F", x+width/2, y+height/2); return; }
        if (myLabel.length() > 0) {
            switch (myLabel) {
                case "1": fill(0,0,255);     break;
                case "2": fill(0,150,0);     break;
                case "3": fill(255,0,0);     break;
                case "4": fill(0,0,150);     break;
                case "5": fill(150,0,0);     break;
                case "6": fill(0,150,150);   break;
                case "7": fill(150,0,150);   break;
                case "8": fill(80,80,80);    break;
                default:  fill(0);           break;
            }
            text(myLabel, x + width/2, y + height/2);
        }
    }

    public void setLabel(String newLabel) { myLabel = newLabel; }
    public void setLabel(int newLabel)    { myLabel = "" + newLabel; }
    public boolean isFlagged()            { return flagged; }
}
