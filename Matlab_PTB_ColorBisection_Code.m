clear all; close all;

participantID=input('What is the participant''s ID?\n');
if exist('recordedData.mat') ~= 2
    save('recordedData.mat')
else
    load('recordedData.mat')
end

Screen('Preference','VisualDebugLevel',3); Screen('Preference','SkipSyncTests',1);Screen('Preference','SuppressAllWarnings',0);
KbName('UnifyKeyNames');rng('shuffle');ListenChar(2);pathOfExperiment=pwd;
escapeKey=KbName('escape');enterKey=KbName('return');spaceKey=KbName('space');fKey=KbName('f');kKey=KbName('k');hKey=KbName('h');qKey=KbName('q');


HideCursor


% Parameters
RSIBackGround=randi(2);
if RSIBackGround==1
    RSIBackGround=[0 0 0];crossColor=[255 255 255];
else
    RSIBackGround=[255 255 255]; crossColor=[0 0 0]; 
end
[windowPtr,windowSize]=Screen('OpenWindow',0,RSIBackGround);x=windowSize(3)/2;y=windowSize(4)/2;

midColor=[1 2 3];
backGround=[1:1:7];

numOfBlocks=8;
RSILimits=[.5 1];meanRSI=0.75;

matrix=repmat(combvec(midColor, backGround)', numOfBlocks,1);

[~,~,keyCode]=KbCheck;
contExp=1;

if randi(2)==1
    BlackKey=1; else
    BlackKey=2;
end
data{participantID}.BlackKey=BlackKey;

try
    for block=1:numOfBlocks
        
        matrix=Shuffle(matrix,2);
        
        for trial=1:size(matrix,1) % This could be a for loop, but a while loop is more efficient
            
            [~,~,keyCode]=KbCheck;
            if find(keyCode==1)==qKey %Emergency quit
                contExp=0;
                break
            end
            
            RSI=exprnd(meanRSI);
            while RSI<RSILimits(1) || RSI>RSILimits(2); RSI=exprnd(meanRSI);end
            
            Screen('FillRect',windowPtr,RSIBackGround);
            Screen('DrawLine',windowPtr,crossColor,x-20,y,x+20,y,10)
            Screen('DrawLine',windowPtr,crossColor,x,y-20,x,y+20,10)
            
            Screen('Flip',windowPtr);WaitSecs(0.5);
            Screen('Flip',windowPtr);WaitSecs(RSI);
            
            whichColor=[];
            if matrix(trial,1)==1
                whichColor=[255 0 0]; %R
            elseif matrix(trial,1)==2
                whichColor=[0 255 0]; %G
            else
                whichColor=[0 0 255]; %B
            end
            
            GrayNum=matrix(trial,2)*15+78;
            whichGray=[GrayNum GrayNum GrayNum];
            Screen('FillRect', windowPtr, whichGray);
            Screen('FillRect', windowPtr, whichColor, [x-70 y-70 x+70 y+70]);
            Screen('Flip', windowPtr);
            WaitSecs(2);
            
            
            noResponse=0;
            QuestionOnset=GetSecs;
            while 1 %Get Response From The Participant
                if GetSecs-QuestionOnset>=3
                    DrawFormattedText(windowPtr,'Too Late!','center','center',RSIBackGround);
                    Screen('Flip',windowPtr);
                    WaitSecs(1);
                    noResponse=1;
                    break
                end
                [~,~,keyCode]=KbCheck;
                if find(keyCode==1)==fKey
                    QuestionOffSet=GetSecs;
                    keyPress=1;
                    if BlackKey==1
                        blackResp=1;
                    else
                        blackResp=0;
                    end
                    break
                elseif find(keyCode==1)==kKey
                    QuestionOffSet=GetSecs;
                    keyPress=2;
                    if BlackKey==2
                        blackResp=1;
                    else
                        blackResp=0;
                    end
                    break
                end
                
                if BlackKey==1
                    DrawFormattedText(windowPtr,'The tone of background color was closer to white or black?\n\nF = BLACK     K=WHITE','center','center',RSIBackGround);
                else
                    DrawFormattedText(windowPtr,'The tone of background color was closer to white or black?\n\nK = BLACK     F=WHITE','center','center',RSIBackGround);
                end
                
                Screen('Flip',windowPtr);
            end
            
            Screen('Flip',windowPtr);
            WaitSecs(0.5);
            
            %RECORD DATA
            
            if noResponse==0
                data{participantID}.reactionTime(trial)=QuestionOffSet-QuestionOnset;
                data{participantID}.keyPress(trial)=keyPress;
                data{participantID}.blackResponse(trial)=blackResp;
            else
                data{participantID}.reactionTime(trial)=NaN;
                data{participantID}.keyPress(trial)=NaN;
                data{participantID}.blackResponse(trial)=NaN;
            end
        end
        
        data{participantID}.matrix=matrix;
        
        
        if contExp==0
            break
        end
    end
    
    
  
catch ME
    save('recordedData.mat')
    sca
    ShowCursor
    ListenChar(0);
    fprintf('THERE WAS AN ERROR:\n')
    rethrow(ME)
end

save('recordedData.mat','data')
sca
ShowCursor
ListenChar(0)
