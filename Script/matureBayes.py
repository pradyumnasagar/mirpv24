import sys
import operator


def removeEOL(line):
    length = len(line)
    if(length == 0):
        return line
    if(line[length-1] == '\n'):
        line = line[0:length-1]
    return line

# Class Precursor keeps precursor information
class Precursor:
    def __init__(self, name, hairpin, pos, data):
        self.name = name
        self.position = pos
        self.hairpin = hairpin
        self.data = data
        self.positionArray = self.extractInfo(self.position, 'mature')
        self.hairpinArray = self.extractInfo(self.hairpin, 'hairpin')
       

    def extractInfo(self, str, strCompare):
        array = []
        tmpStr = str.split('\t')
        for p in tmpStr:
            if p.startswith(strCompare):
                tmp = p.split(':')
                array.append([int(tmp[1]), int(tmp[2])])
        return array

class CandidateMature:
    """ Keeps all the necessary information of a possible candidate. """
    def __init__(self, startPosition, length, stem, score, duplexSP):
        self.startPos = startPosition
        self.length = length
        self.stem = stem
        self.score = score
        self.duplexStartPos = duplexSP

    def compare(self, cand1, cand2):
        return cmp(float(cand1.score), float(cand2.score))

class PositionFeature:
    """ Implements a position feature of the Bayesian Classifier.
    Keeps the probabilities of the feature for both positive
    and negative class."""
    def __init__(self, id, pos=0, neg=0):
        """ id : the identifier of the feature. """
        self.id = id
        self.posProbability = pos
        self.negProbability = neg

    def increasePosProbability(self):
        self.posProbability += 1

    def increaseNegProbability(self):
        self.negProbability += 1

    def normalizePosProbability(self, norm):
        if self.posProbability == 0:
            self.posProbability = 0.000001
        else :
            self.posProbability /= float(norm)

    def normalizeNegProbability(self, norm):
        if self.negProbability == 0:
            self.negProbability = 0.000001
        else :
            self.negProbability /= float(norm)

class DistanceFeature:
    """ Implements a distance feature for
    the Bayesian Classifier. Keeps probability for all
    values, both positive and negative classes. """

    def __init__(self, id):
        self.id = id
        self.positiveValues = {}
        self.negativeValues = {}

    def increasePosProbability(self, value):
        try:
            self.positiveValues[value] = self.positiveValues[value] + 1
        except KeyError:
            self.positiveValues[value] = 1

        return

    def increaseNegProbability(self, value):
        try:
            self.negativeValues[value] = self.negativeValues[value] + 1
        except KeyError:
            self.negativeValues[value] = 1
        return

    def normalizePosProbability(self, norm):
        for v in self.positiveValues:
            self.positiveValues[v] = self.positiveValues[v] / float(norm)
        return

    def normalizeNegProbability(self, norm):
        for v in self.negativeValues:
            self.negativeValues[v] = self.negativeValues[v] / float(norm)
        return
    
    def setPosProbability(self, value, prob):
        self.positiveValues[value] = prob
        return

    def getPosProbability(self, value):
        try:           
            return(self.positiveValues[value])
        except KeyError:
            return (0.0000000000001)
    
    def setNegProbability(self, value, prob):
        self.negativeValues[value] = prob
        return

    def getNegProbability(self, value):
        try:           
            return(self.negativeValues[value])
        except KeyError:
            return (0.0000000000001)


            
class BayesianClassifier:
    """ Implements the bayesian classifier. """
    def __init__(self, around, positionsNames=[], relativeNames=[]):   
       
        # the length of flanking region around mature
        self.around = around
        # a list of positions used as features
        self.positions = positionsNames
        # Position Oriented Features
        self.features = []
        # create all possible combinations of features
        featuresName = self.__createFeaturesName(self.positions)
        for i in range(0, len(featuresName)):
            self.features.append(PositionFeature(featuresName[i]))
        # Distance Oriented Features 
        self.relativePosStem5 = []
        self.relativePosStem3 = []
        for i in range(0, len(relativeNames)):
            self.relativePosStem5.append(DistanceFeature(relativeNames[i]))
            self.relativePosStem3.append(DistanceFeature(relativeNames[i]))
        return

    
    
    ############# Function for  position oriented features  ####################

    def __createFeaturesName(self, positions):
        """ Create all possible combinations of features."""
        positionsLen = len(positions)
        featuresName = []
        for i in range(0, positionsLen):
            feature = positions[i] + ':A_match'
            featuresName.append(feature)  
            feature = positions[i] + ':A_mismatch'
            featuresName.append(feature)  
            feature = positions[i] + ':C_match'
            featuresName.append(feature)  
            feature = positions[i] + ':C_mismatch'
            featuresName.append(feature)  
            feature = positions[i] + ':G_match'
            featuresName.append(feature)  
            feature = positions[i] + ':G_mismatch'
            featuresName.append(feature)  
            feature = positions[i] + ':U_match'
            featuresName.append(feature)  
            feature = positions[i] + ':U_mismatch'
            featuresName.append(feature)  
            feature = positions[i] + ':noValue_noValue'
            featuresName.append(feature)  
        return featuresName

    def __findFeature(self, id):
        for i in range(0, len(self.features)):
          #  print self.features[i].id
            if self.features[i].id == id :
                return i
        return -1


    def __getPosFromID(self, id, line):
        tmp = id.split('_')[1]
        tmp = tmp.split('-')
        pos = int(tmp[0])
        if tmp[1] == 'end':
            pos = len(line) - pos - 1 # -1 due to array arithmetic
        return pos

    def extractFeatures(self, line):
        """ Extracts features of a mirna.
        line: the data that describe the mirna, eg sequence,
        structure, etc."""
        featuresName = []
        for i in range(0, len(self.positions)):
            #pos = self.__getPosFromID(self.positions[i].id, line[0])
            pos_split = self.positions[i].split('_')
            pos_len = len(pos_split)   
            featureName =  self.positions[i] + ':'
            # calculate the position basedon mature or the flanking regions
            pos = int(pos_split[1])
            if pos_split[2] == 'm':
                pos = self.around + pos
            elif pos_split[2] == 'b':
                pos = self.around - pos
            else:
                pos = len(line[0]) - 1 - self.around + pos
            
            for j in range(3, pos_len):
                if pos >= len(line[0]):
                #print 'No position ' + str(pos) + ' len=' + str(len(line[0]))
                #return ''
                    featureName = featureName + 'noValue'
                    if j != (pos_len-1):
                        featureName = featureName + '_'
                    else:
                        featureName = featureName + ' '

                # secondary structure feature of position pos
                elif pos_split[j]=='str':   
                    for k in range(0, len(line)):
                        if line[k][pos] == '.':  
                            featureName = featureName + 'mismatch' 
                            if j != (pos_len-1):
                                featureName = featureName + '_'
                            else:
                                featureName = featureName + ' '
                            break
                        elif line[k][pos] == ')' or  line[k][pos] == '(':
                            featureName = featureName + 'match' 
                            if j != (pos_len-1):
                                featureName = featureName + '_'
                            else:
                                featureName = featureName + ' '
                            break
                        elif line[k][pos] == '-':
                             featureName = featureName + 'noValue' 
                             if j != (pos_len-1):
                                featureName = featureName + '_'
                             else:
                                featureName = featureName + ' '
                             break
                # sequence feature of position pos
                elif pos_split[j]=='seq':
                    for k in range(0, len(line)):
                        if line[k][pos].isalpha():
                            featureName = featureName + line[k][pos] 
                            if j != (pos_len-1):
                                featureName = featureName + '_'
                            else:
                                featureName = featureName + ' '
                            break
                        elif line[k][pos] == '-':
                            featureName = featureName + 'noValue'
                            if j != (pos_len-1):
                                featureName = featureName + '_'
                            else:
                                featureName = featureName + ' '
                            break
                # conservation feature of position pos
                elif pos_split[j]=='cons':
                    for k in range(0, len(line)):
                        if line[k][pos] == '*':  
                            featureName = featureName + 'cons' 
                            if j != (pos_len-1):
                                featureName = featureName + '_'
                            else:
                                featureName = featureName + ' '
                            break
                        elif line[k][pos] == '-':
                            featureName = featureName + 'nonCons'
                            if j != (pos_len-1):
                                featureName = featureName + '_'
                            else:
                                featureName = featureName + ' '
                            break
            featuresName.append(featureName)
        return featuresName

   
                   
   
    
    ############# Functions of distance oriented features ################
    def findRelativePositionFeature(self, id):
        length = len(self.relativePosStem5)
        for i in range(0, length):
            #  print self.features[i].id
            if self.relativePosStem5[i].id == id :
                return i
        return -1  


    def normalizeRelativePositionsProbabilities(self, normPos, normNeg, stem):
        if stem == 'Stem:5':
            for relPos in self.relativePosStem5:
                relPos.normalizePosProbability(normPos)
                relPos.normalizeNegProbability(normNeg)
        else:
            for relPos in self.relativePosStem3:
                relPos.normalizePosProbability(normPos)
                relPos.normalizeNegProbability(normNeg)

    ##################################

    def saveClassifier(self, file):
        """ Saves the classifier in a file."""
        fOut = open(file, 'w')
        fOut.write('Relative Distances 5 stem::\n')
        for i in range(0, len(self.relativePosStem5)):
            fOut.write(self.relativePosStem5[i].id+'\n')
            fOut.write('\tPositive Values::\n')
            for k, v in self.relativePosStem5[i].positiveValues.iteritems():
                fOut.write('\t' + str(k) + '\t' + str(v) + '\n')
            fOut.write('\tNegative Values::\n')
            for k, v in self.relativePosStem5[i].negativeValues.iteritems():
                fOut.write('\t' + str(k) + '\t' + str(v) + '\n')

        fOut.write('Relative Distances 3 stem::\n')
        for i in range(0, len(self.relativePosStem3)):
            fOut.write(self.relativePosStem3[i].id+'\n')
            fOut.write('\tPositive Values::\n')
            for k, v in self.relativePosStem3[i].positiveValues.iteritems():
                fOut.write('\t' + str(k) + '\t' + str(v) + '\n')
            fOut.write('\tNegative Values::\n')
            for k, v in self.relativePosStem3[i].negativeValues.iteritems():
                fOut.write('\t' + str(k) + '\t' + str(v) + '\n')   
           

        fOut.write('Features::\n')
        for i in range(0, len(self.positions)):
            fOut.write(self.positions[i]+'\n')
        fOut.write('Probabilities::\n')
        for i in range(0, len(self.features)):
            fOut.write(self.features[i].id+'\n')
            fOut.write('\tPos\t' + str(self.features[i].posProbability)+'\n')
            fOut.write('\tNeg\t' + str(self.features[i].negProbability)+'\n')
        fOut.close()
        return
        
    def retrieveClassifier(self, fileIn):
        """ Retrieves an old classifier from a file."""
        fIn = open(fileIn, 'r')
        line = fIn.readline()
       
        if line.find('Relative Distances 5 stem') != -1:
            line = fIn.readline()
            while line.find('Relative Distances 3 stem') == -1:
                line = removeEOL(line)
                self.relativePosStem5.append(DistanceFeature(line))
                arrayLen = len(self.relativePosStem5)
                line = fIn.readline()
                line = fIn.readline() # ignore '\tPositive Values' line
                # extract positive probability for distance feature
                while line.find('Negative Values') == -1:
                    data = line.split()
                    self.relativePosStem5[arrayLen-1].setPosProbability(float(data[0]),
                                                                        float(data[1]))
                    line = fIn.readline()
                line = fIn.readline() # ignore '\tNegative Values' line
                # extract negative probability for distance feature
                while line.startswith('\t'):
                    data = line.split()
                    self.relativePosStem5[arrayLen-1].setNegProbability(float(data[0]),
                                                                        float(data[1]))
                    line = fIn.readline()
        
        if line.find('Relative Distances 3 stem') != -1:
            line = fIn.readline()
            while line.find('Features') == -1:
                line = removeEOL(line)
                self.relativePosStem3.append(DistanceFeature(line))
                arrayLen = len(self.relativePosStem3)
                line = fIn.readline()
                line = fIn.readline() # ignore '\tPositive Values' line
                # extract positive probability for distance feature
                while line.find('Negative Values') == -1:
                    data = line.split()
                    self.relativePosStem3[arrayLen-1].setPosProbability(float(data[0]),
                                                                        float(data[1]))
                    line = fIn.readline()
                line = fIn.readline() # ignore '\tNegative Values' line
                # extract negative probability for distance feature
                while line.startswith('\t'):
                    data = line.split()
                    self.relativePosStem3[arrayLen-1].setNegProbability(float(data[0]),
                                                                        float(data[1]))
                    line = fIn.readline()
                

        if line.find('Features::') != -1:
            line = fIn.readline()
            while line.find('Probabilities') == -1:               
                line = removeEOL(line)
                self.positions.append(line)
                line = fIn.readline()
        
        if line.find('Probabilities') != -1:
            line = fIn.readline()
            while line.startswith('Position_'):
                # extract feature probabilities
                id = removeEOL(line)
                line = fIn.readline()
                posProb = line.split()
                line = fIn.readline()
                negProb = line.split()
                self.features.append(PositionFeature(id, 
                                      float(posProb[1]), float(negProb[1])))
                # get next feature
                line = fIn.readline()
        fIn.close()
        return
        
    ######################################       

    def findProbPositionFeatures(self, data):
        """ Returns the classification value pos/neg fraction."""
        fName = self.extractFeatures(data)
        posProb = 1
        negProb = 1
        for i in range(0, len(fName)):
            index = self.__findFeature(fName[i])
            if index == -1:
                continue
            posProb = posProb * self.features[index].posProbability
            negProb = negProb * self.features[index].negProbability
        return [posProb,negProb]

    def findProbRelativePositionsFeatures(self, stem,
                           relativeStartHairpin,relativeStartEnds,
                            relativeEndHairpin, relativeEndEnds):
        posProb = 1
        negProb = 1
        if stem == 'Stem:5':
            for relPos in self.relativePosStem5:
                if relPos.id == 'Hairpin_Start':
                   posProb = posProb * relPos.getPosProbability(relativeStartHairpin)
                   negProb = negProb * relPos.getNegProbability(relativeStartHairpin)
                elif relPos.id == 'Hairpin_End':
                   posProb = posProb * relPos.getPosProbability(relativeEndHairpin)
                   negProb = negProb * relPos.getNegProbability(relativeEndHairpin)
                elif relPos.id == 'End_Start':
                   posProb = posProb * relPos.getPosProbability(relativeStartEnds)
                   negProb = negProb * relPos.getNegProbability(relativeStartEnds)
                elif relPos.id == 'End_End':
                   posProb = posProb * relPos.getPosProbability(relativeEndEnds)
                   negProb = negProb * relPos.getNegProbability(relativeEndEnds)
        else:
            for relPos in self.relativePosStem3:
                if relPos.id == 'Hairpin_Start':
                   posProb = posProb * relPos.getPosProbability(relativeStartHairpin)
                   negProb = negProb * relPos.getNegProbability(relativeStartHairpin)
                elif relPos.id == 'Hairpin_End':
                   posProb = posProb * relPos.getPosProbability(relativeEndHairpin)
                   negProb = negProb * relPos.getNegProbability(relativeEndHairpin)
                elif relPos.id == 'End_Start':
                   posProb = posProb * relPos.getPosProbability(relativeStartEnds)
                   negProb = negProb * relPos.getNegProbability(relativeStartEnds)
                elif relPos.id == 'End_End':
                   posProb = posProb * relPos.getPosProbability(relativeEndEnds)
                   negProb = negProb * relPos.getNegProbability(relativeEndEnds)
        
        return [posProb, negProb]

    ###################################################
    
    def getMatureCandidatesPerPrecursor(self, windowLen, filesInSeq, filesInStr, 
                                        fileOut):
        """ Gives the mature mirna candidates per precursor 
        sorted by stem and score"""
       
        fOut = file(fileOut, 'w')
        precursorsArray = self.createPrecursorDataFromStructure(filesInSeq, filesInStr)
        for prec in precursorsArray:
            precLen = len(prec.data[0])
            lenPosition = len(prec.positionArray)
            lenHairpin = len(prec.hairpinArray)
            candidateStem5 = []
            candidateStem3 = []
            
            # create all possible mature mirna of length windowLen 
            # from both stems of the  precursor.
            startPosition = 0
            endPosition = prec.hairpinArray[0][0]
            stem = '5'
            for h in range(0, len(prec.hairpinArray)+1):
                stemLimits = range(startPosition, endPosition)
                for i in stemLimits: # i = the position candidate starts  
                    if (i + windowLen) >= precLen:
                        continue
                    if stem == '5':
                        relativeStartHairpin = prec.hairpinArray[0][0] - i
                        relativeStartEnds = i
                        relativeEndHairpin = prec.hairpinArray[0][0] - (i + windowLen)
                        relativeEndEnds = i + windowLen
                    else:
                        relativeStartHairpin = i - prec.hairpinArray[0][1]
                        relativeStartEnds = precLen - i
                        relativeEndHairpin = (i + windowLen) - prec.hairpinArray[0][1]
                        relativeEndEnds = precLen - (i+windowLen)
                    # For all data files
                    mirnaMature = []
                    for j in range(0, len(prec.data)):
                        mirnaTmp = ''
                        start = i - self.around
                        for k in range(0, self.around):
                            if (start+k) < 0:
                                mirnaTmp += '-'
                            else:
                                mirnaTmp += prec.data[j][start+k]
                        mirnaTmp += prec.data[j][i:i+windowLen]
                        start = i+windowLen
                        precLen = len(prec.data[j])
                        for k in range(0, self.around):
                            if (start+k) >= precLen:
                                mirnaTmp += '-'
                            else:
                                mirnaTmp += prec.data[j][start+k]
                        mirnaMature.append(mirnaTmp)
                    [posProb1, negProb1] = self.findProbPositionFeatures(mirnaMature)
                    [posProb2, negProb2] = self.findProbRelativePositionsFeatures(stem,
                                           relativeStartHairpin,relativeStartEnds,
                                           relativeEndHairpin, relativeEndEnds)
                    score = (posProb1*posProb2) / float(negProb1*negProb2)    
                    duplexSP = self.findMirnaDuplex(prec, i, windowLen, stem)
                    candidateMature = CandidateMature(i, windowLen, stem, 
                                                      score, duplexSP)
                    if stem == '5':
                        candidateStem5.append(candidateMature)
                    else:
                        candidateStem3.append(candidateMature)
                # end of candidates for a stem                   
                # get next limits
                if h < lenHairpin:
                    startPosition = prec.hairpinArray[h][1]
                    stem = '3'
                    if (h+1) < lenHairpin:
                        endPosition = prec.hairpinArray[h+1][0]
                    else:
                        endPosition = precLen - windowLen                                 
            # end of all stems   
            #sort candidates per stem per score
            candidateStem5.sort(key=operator.attrgetter('score'))
            candidateStem5.reverse()
            candidateStem3.sort(key=operator.attrgetter('score'))
            candidateStem3.reverse()
            fOut.write(prec.name + '\t' + prec.hairpin + '\n')
            fOut.write(prec.data[0] + '\n')
            #fOut.write('Start_Position\tScore\tStem\tDuplex_Start_Position\n')
            m = candidateStem5[0]
            #for m in candidateStem5:
            fOut.write(str(m.startPos) + '\t' + str(m.score) +
                           '\t' +  m.stem + '\t' + str(m.duplexStartPos)+'\n')
            m = candidateStem3[0]
            #for m in candidateStem3:
            fOut.write(str(m.startPos) + '\t' + str(m.score) +
                           '\t' + m.stem + '\t' + str(m.duplexStartPos)+ '\n')
        # end of precursors          
        fOut.close()
        return



    def findMirnaDuplex(self, prec, position, windowLen, stem):
        """ Calculates the starting position of the mature candidates duplex."""
        endMatch = position+windowLen

        # position on 5' stem:
        if stem == '5':
            while prec.data[1][endMatch] != '(':   
                endMatch -= 1
            countMatches = 1
            #print endMatch
            if endMatch < position :
                return -1        
            while countMatches != 0:
                endMatch += 1
                if prec.data[1][endMatch] == '(':
                    countMatches += 1
                elif prec.data[1][endMatch] == ')':
                    countMatches -= 1
        else: # position on 3' stem:
            while prec.data[1][endMatch] != ')':
                endMatch -= 1
            countMatches = 1
            if endMatch < position:
                return -1
            #print endMatch
            while countMatches != 0:
                endMatch -= 1
                if prec.data[1][endMatch] == '(':
                    countMatches -= 1
                elif prec.data[1][endMatch] == ')':
                    countMatches += 1
        if (endMatch+2) >= len(prec.data[1]):
        #  print 'EndMatch', endMatch
            return (endMatch)
        else:
        #    print 'EndMatch', endMatch+2
            return (endMatch+2)
        

    def createPrecursorDataFromStructure(self, filePre, fileStruct):
        """ Create an array with the precursors.
        filePre = contains the sequence of the precursors in fasta format.
        fileStruct = contains data produced from RNAfold for each precursor."""
        finPre = open(filePre, 'r')
        finStr = open(fileStruct, 'r')
        precursorArray = []

        line = finPre.readline()
        while(line != '') :
            if(line[0] == '>'):
                # ignore \n at the end of line
                if(line[len(line)-1] == '\n'):
                    line = line[0:len(line)-1]
                mirnaName = line

                seq = finPre.readline()
                # ignore \n at the end of line
                if(seq[len(seq)-1] == '\n'):
                    seq = seq[0:len(seq)-1]


                # get structure information
                # rnafold provides the limits of the hairpin not the actual hairpin
                # in order to retrive the exact position in python counting in the lower
                # limit we add +1 for the true pos -1 due to zero arithmetic, while in the
                # upper limit we add -1 fro the true pos and -1 due to zero arithmetic. 
                hairpin = ''
                lineStruct = finStr.readline()
                while(lineStruct != '' and lineStruct[0] != '(' and lineStruct[0] != '.'):
                    if lineStruct.startswith('Hairpin') :
                        tmp = lineStruct.split('(')
                        tmp = tmp[1].split(')')
                        tmp = tmp[0].split(',')
                        hairpin += 'hairpin:' +tmp[0].strip() + ':' +\
                              str(int(tmp[1].strip())-2) +'\t'
                        #print hairpin

                    lineStruct = finStr.readline()
                struct = lineStruct.split(' ') 
                pos = ''

                pr = Precursor(mirnaName,  hairpin, pos, [seq, struct[0]])
                precursorArray.append(pr)
            line = finPre.readline()
        finPre.close()
        finStr.close()
        return precursorArray

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print 'Usage::python matureBayes sequenceInput structureInput output'
        sys.exit(1)
    around = 9
    windowLen = 22
   
    b = BayesianClassifier(around)
    b.retrieveClassifier('bayesianClassifier.txt')
    b.getMatureCandidatesPerPrecursor(windowLen, sys.argv[1], sys.argv[2], sys.argv[3]) 
  
