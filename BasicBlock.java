import java.util.ArrayList;
import java.util.List;

public class BasicBlock {

    private List<Instruction> instructions; // holds all the instructions
    private int firstLineNum;     // start line of a basic block
    
    // constructor
    public BasicBlock(int start, List<Instruction> ir) {
        instructions = ir;
        firstLineNum = start;
    }
    
    // retrieves all instructions from the BasicBlock
    public ArrayList<Instruction> getInstructions() {
        return (ArrayList<Instruction>) instructions;
    }
    
    // first index that this block begins with
    public int getFirstLineNum() {
        return firstLineNum;
    }


    //@TODO Add more to the basic block as needed

    public void insertInstruction(Instruction instr) {
        instructions.add(instr);
    }
}
