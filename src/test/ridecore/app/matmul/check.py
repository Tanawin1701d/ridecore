with open('/media/tanawin/tanawin1701e/project2/Kathryn/extSim/ridecore/src/test/ridecore/app/matmul/stencil.txt', 'r') as f:
    lines = f.readlines()
    lines = lines[::2]
    numBuf = ""
    
    for line in lines:
        line = line.rstrip('\n')

        if (line == '44' or line == '10'):
            if numBuf:  # Only convert if numBuf is not empty
                result = int(numBuf, 16)
                print(result, end = "")
            numBuf = ""
            if (line == '44'):
                print(" ,", end = "")
            else:
                print("\n", end = "")
            continue
            
        else:
            numBuf = numBuf + chr(int(line))