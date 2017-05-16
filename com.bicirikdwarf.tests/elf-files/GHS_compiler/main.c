typedef unsigned char byte;

int globalVariable;

typedef struct {
    char ch;
} SimpleStruct;

typedef struct {
    SimpleStruct structArray[2];
    byte byteVar;
} ChildStruct;

typedef struct {
    char* charPointer;
    ChildStruct childStruct;
    int multiDimArray[2][2][4];
} ParentStruct;

int main(void) {

    SimpleStruct simpleStruct0;
    simpleStruct0.ch = 'a';

    SimpleStruct simpleStruct1;
    simpleStruct1.ch = 'b';

    ChildStruct predefinedChildStruct;
    predefinedChildStruct.byteVar = 65;
    predefinedChildStruct.structArray[0] = simpleStruct0;
    predefinedChildStruct.structArray[1] = simpleStruct1;

    ParentStruct parentStruct;
    parentStruct.charPointer = 'a';
    parentStruct.childStruct = predefinedChildStruct;
    parentStruct.multiDimArray[0][0][0] = 0;
    parentStruct.multiDimArray[0][1][0] = 1;
    parentStruct.multiDimArray[1][0][0] = 2;
    parentStruct.multiDimArray[1][1][0] = 3;

    return 0;
}

