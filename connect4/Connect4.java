import java.util.ArrayList;
import java.util.Collections;
import java.util.Scanner;
import java.util.List;
import java.util.stream.*;
import java.lang.IllegalArgumentException;
import java.util.InputMismatchException;
import java.util.NoSuchElementException;

class Grid {
    final int nColumns;
    final int nRows;
    final int streak;
    ArrayList<String> grid;
    int rounds;

    public Grid(int nColumns, int nRows, int streak) {
        this.nColumns = nColumns;
        this.nRows = nRows;
        this.streak = streak;
        this.grid = new ArrayList<String>(Collections.nCopies(nColumns * nRows, "."));
    }

    public void printGrid() {
        String indices = IntStream.range(0, nColumns)
            .mapToObj(String::valueOf)
            .collect(Collectors.joining(" ", " ", ""));

        System.out.println(indices);

        for (int i = grid.size(); i > 0; i -= nColumns) {
            String row = grid.subList(i - nColumns, i)
                .stream()
                .collect(Collectors.joining("|", "|", "|"));
            System.out.println(row);
        }
    }

    public int insertToken(int column, String token)
        throws InvalidPlayException,FullGridException {
        int position = 0;
        
        if (column < 0 || column > nColumns - 1) {
            throw new IllegalArgumentException(String.format("Token has be placed between 0 and %d",
                                                             nColumns - 1));
        }
        
        for (int i = column; i < grid.size(); i += nColumns) {
            if (grid.get(i).equals(".")) {
                grid.set(i, token);
                ++rounds;
                position = i;
                break;
            }
        }

        if (position > grid.size()) {
            throw new InvalidPlayException("INVALID MOVE: Column is full");
        } else if (rounds > grid.size()) { // FIX: This  will prevent  a player to  win on  the last
                                           // token
            throw new FullGridException("ENDGAME: grid is full");
        }
        
        return position;
    }

    public boolean isWinningPlay(int position, String token) {
        String horizontal = getHorizontalLine(position);
        String vertical = getVerticalLine(position);
        String ascending = getAscendingLine(position);
        String descending = getDescendingLine(position);

        String match = token.repeat(streak);
        
        return horizontal.contains(match) ||
            vertical.contains(match) || 
            ascending.contains(match) ||
            descending.contains(match);
    }

    private String getHorizontalLine(int position) {
        int start = position / nColumns;

        return generateSequence(start, 1, start + nColumns)
            .stream()
            .map(x -> grid.get(x))
            .collect(Collectors.joining(""));
    }
    
    private String getVerticalLine(int position) {
        int start = position % nColumns;

        return generateSequence(start, nColumns, grid.size() - 1)
            .stream()
            .map(x -> grid.get(x))
            .collect(Collectors.joining(""));
    }

    private String getAscendingLine(int position) {
        int start = findAscendingStart(position);
        int end = findAscendingEnd(position);

        return generateSequence(start, nColumns + 1, end)
            .stream()
            .map(x -> grid.get(x))
            .collect(Collectors.joining(""));
    }

    private int findAscendingStart(int position) {
        if (position < nColumns || position % nColumns == 0) {
            return position;
        }
        return findAscendingStart(position - (nColumns + 1));
    }

    private int findAscendingEnd(int position) {
        if (position > grid.size() - nColumns || position % nColumns == nColumns - 1) {
            return position;
        }
        return findAscendingEnd(position + (nColumns + 1));
    }

    private String getDescendingLine(int position) {
        int start = findDescendingStart(position);
        int end = findDescendingEnd(position);

        return generateSequence(end, nColumns - 1, start)
            .stream()
            .map(x -> grid.get(x))
            .collect(Collectors.joining(""));
    }

    private int findDescendingStart(int position) {
        if (position > grid.size() - nColumns || position % nColumns == 0) {
            return position;
        }
        return findDescendingStart(position + (nColumns - 1));
    }

    private int findDescendingEnd(int position) {
        if (position < nColumns || position % nColumns == nColumns - 1) {
            return position;
        }
        return findDescendingEnd(position - (nColumns - 1));
    }
    
    // end is inclusive
    private List<Integer> generateSequence(int start, int increment, int end) {
        List<Integer> sequence = new ArrayList<>();

        for (int i = start; i <= end; i += increment) {
            sequence.add(i);
        }
        
        return sequence;
    }
}

class InvalidPlayException extends Exception {
    public InvalidPlayException(String msg) {
        super(msg);
    }
}

class FullGridException extends Exception {
    public FullGridException(String msg) {
        super(msg);
    }
}

public class Connect4 {
    public static void main(String args[]) {
        Grid grid = new Grid(7, 6, 4);

        String token = "x";
        Scanner sc = new Scanner(System.in);
        
        do {
            grid.printGrid();
            System.out.print("Insert token into: ");
            
            try {
                int column = sc.nextInt();

                int position = grid.insertToken(column, token);
                if (grid.isWinningPlay(position, token)) {
                    System.out.printf("Player %s wins!\n", token);
                    grid.printGrid();
                    break;
                } else {
                    token = flip(token);
                }
            } catch (FullGridException e) {
                System.out.println(e.getMessage());
                break;
            } catch (InputMismatchException e) {
                System.out.println(e.getMessage() + ": must be a number");
                sc.next();
            } catch (NoSuchElementException e) {
                System.out.println("BYE");
            } catch (Exception e) {
                System.out.println(e.getMessage());
            } 
        } while (sc.hasNextLine());

        sc.close();
    }

    static String flip(String token) {
        return (token.equals("x")) ? "o" : "x";
    }
}
