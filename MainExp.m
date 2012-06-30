function [recPatDecisionTime, recExpDecisionTime, recPatChoice, recExpChoice, recWinner] = MainExp()
%MAIN The app implements the scheme that asks the patient to press down 
%  buttons as soon as he/she makes the decision. It counts from 5 - 1 then 
%  GO-GO-GO. Patient can play with either computer or human

clear all;
rng;

%% parameters
patName         = 'Patient';    % patient name
expName         = 'Uri';        % experimenter name
initialMoney    = 5;            % initial endowment
rounds          = 20;            % rounds

%% set up
recPatDecisionTime = zeros(rounds, 1);
recExpDecisionTime = zeros(rounds, 1);
recPatChoice = zeros(rounds, 1);
recExpChoice = zeros(rounds, 1);
recWinner = zeros(rounds, 1);

patMoney = initialMoney;
expMoney = initialMoney;

res = RespBox();
scr = Screen();

%% initial stage
scr.initiate(patName,expName,initialMoney);
scr.setMainText('Please put your hands down to start');

res.setVal([1 0 1 0 0 1 0 1]);
res.monitorTargetWait([1 1 1 1]);
res.clearVal();
scr.setMainText('When you are ready, lift both hands to start the game');
res.monitorTargetWait([0 0 0 0]);

%% trial stage
for i = 1:rounds
    % COUNT DOWN
    scr.setP1Text(''); scr.setP2Text('');
    res.setVal([1 0 1 0 0 1 0 1]);
    t = timer('StartDelay', 0, 'Period', 1, 'TasksToExecute', 5, ...
        'ExecutionMode', 'fixedRate');
    t.TimerFcn = {@updateCountdown, scr};
    tid = tic;
    start(t);
    
    ret = res.monitor2TargetsWaitTime([1 1 0 0], [0 0 1 1], 5);
    if cmpBtns(ret, [1 1 0 0])
        recPatDecisionTime(i) = toc(tid); 
        ret = res.monitorTargetWaitTime([1 1 1 1], 5-toc(tid));
        recExpDecisionTime(i) = toc(tid); 
    else
        recExpDecisionTime(i) = toc(tid); 
        ret = res.monitorTargetWaitTime([1 1 1 1], 5-toc(tid));
        recPatDecisionTime(i) = toc(tid); 
    end
    
    if cmpBtns(ret, [1 1 0 0]) || cmpBtns(ret, [1 1 1 0]) % experimenter too slow
        stop(t);
        scr.setMainText(sprintf('%s did not make your decision fast enough. Please put your hands down to coninue', expName));
        expMoney = expMoney - .1;
        scr.setMoney(1, expMoney);
        res.setVal([1 0 1 0 0 1 0 1]);
        res.monitorTargetWait([1 1 1 1]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        delete(t);
        continue;
    elseif cmpBtns(ret, [0 0 1 1]) || cmpBtns(ret, [0 1 1 1]) % patient too slow
        stop(t);
        scr.setMainText(sprintf('%s did not make your decision fast enough. Please put your hands down to coninue', patName));
        patMoney = patMoney - .1;
        scr.setMoney(1, patMoney);
        res.setVal([1 0 1 0 0 1 0 1]);
        res.monitorTargetWait([1 1 1 1]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        delete(t);
        continue;
    elseif ~cmpBtns(ret, [1 1 1 1]) % both too slow
        stop(t);
        scr.setMainText(sprintf('Both did not make your decision fast enough. Please put your hands down to coninue'));
        patMoney = patMoney - .1;
        expMoney = expMoney - .1;
        scr.setMoney(1, patMoney);
        scr.setMoney(1, expMoney);
        res.setVal([1 0 1 0 0 1 0 1]);
        res.monitorTargetWait([1 1 1 1]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        delete(t);
        continue;
    end
    res.setVal([0 0 0 0 0 0 0 0]);
    ret = res.monitorChangeWaitTime(5-toc(tid));
    if ~cmpBtns(ret,[-1 -1 -1 -1]) % lift hands too early
        stop(t);
        if cmpBtns(ret,[1 1 1 0]) || cmpBtns(ret,[1 1 0 0])
            scr.setMainText(sprintf('%s lift hands too early. Please put your hands down', expName));
            expMoney = expMoney - .1;
            scr.setMoney(2, expMoney);
        elseif cmpBtns(ret,[0 0 1 1]) || cmpBtns(ret,[0 1 1 1])
            scr.setMainText(sprintf('%s lift hands too early. Please put your hands down', patName));
            patMoney = patMoney - .1;
            scr.setMoney(1, patMoney);
        else
            scr.setMainText('both lift hands too early. Please put your hands down');
            expMoney = expMoney - .1;
            scr.setMoney(2, expMoney);
            patMoney = patMoney - .1;
            scr.setMoney(1, patMoney);
        end
        res.setVal([1 0 1 0 0 1 0 1]);
        res.monitorTargetWait([1 1 1 1]);
        res.clearVal();
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        delete(t);
        continue;
    end
    delete(t);
    
    % GET DECISIONS
    scr.setMainText('GO-GO-GO');   
    pause(0.5);
    choice = res.getVal();
    
    err = [0 0];
    if cmp2Btns(choice(1:2),[1 0]) % right hand
        recPatChoice(i) = 1;
        scr.setP1Text('X  O');
    elseif cmp2Btns(choice(1:2),[0 1]) %left hand
        recPatChoice(i) = 2;
        scr.setP1Text('O  X');
    elseif cmp2Btns(choice(1:2),[1 1]) % too late
        err(1) = 1;
        scr.setP1Text('X  X');
    else % both hands up
        err(1) = 2;
        scr.setP1Text('O  O');
    end
    
    if cmp2Btns(choice(3:4),[1 0]) % right hand
        recExpChoice(i) = 1;
        scr.setP2Text('X  O');
    elseif cmp2Btns(choice(3:4),[0 1]) %left hand
        recExpChoice(i) = 2;
        scr.setP2Text('O  X');
    elseif cmp2Btns(choice(3:4),[1 1]) % too late
        err(2) = 1;
        scr.setP2Text('X  X');
    else % both hands up
        err(2) = 2;
        scr.setP2Text('O  O');
    end
    
    if cmpBtns(choice,[-1 -1 -1 -1]) % both too late
        err = [1 1];
        scr.setP1Text('X  X');
        scr.setP2Text('X  X');
    end
        
    % HANDLE THE ERRORS
    if err(1) > 0; patMoney = patMoney - .1; scr.setMoney(1, patMoney); end
    if err(2) > 0; expMoney = expMoney - .1; scr.setMoney(2, expMoney); end
    if sum(err) > 0
        errStr = '';
        if err(1) == err(2)
            if err(1) == 1; errStr = 'Both are too late. ';
            else errStr = 'Both lift both hands. '; end
        end
        if err(1) == 1
            errStr = sprintf('%s is too late. ', patName);
        elseif err(1) == 2
            errStr = sprintf('%s lift hands too early. ', patName);
        end
        if err(2) == 1
            errStr = sprintf('%s%s is too late. ', errStr, expName);
        elseif err(2) == 2
            errStr = sprintf('%s%s lift hands too early. ', errStr, expName);
        end
        scr.setMainText([errStr, 'Please put your hands down.']);
        res.setVal([1 0 1 0 0 0 0 0]);
        res.monitorTargetWait([1 1 1 1]);
        res.clearVal();
        pause(0.5);
        scr.setMainText('When you are ready, lift both hands to continue the next round');
        res.monitorTargetWait([0 0 0 0]);
        continue;
    end
    
    % ANNOUNCE THE WINNER
    if recExpChoice(i) == recPatChoice(i) % experimenter wins
        recWinner(i) = 1;
        scr.setMainText(sprintf('%s wins!', expName));
        patMoney = patMoney - .1;
        expMoney = expMoney + .1;
        scr.setMoney(1, patMoney);
        scr.setMoney(2, expMoney);
    else % patient wins
        recWinner(i) = 2;
        scr.setMainText(sprintf('%s wins!', patName));
        patMoney = patMoney + .1;
        expMoney = expMoney - .1;
        scr.setMoney(1, patMoney);
        scr.setMoney(2, expMoney);
    end
    
    res.clearVal();
    scr.setMainText('Please lift your hands');
    res.monitorTargetWait([0 0 0 0]);
    
end

if patMoney > expMoney
    scr.setMainText(sprintf('Session Ended. %s is the winner', patName));
elseif patMoney < expMoney
    scr.setMainText(sprintf('Session Ended. %s is the winner', expName));
else 
    scr.setMainText('Session Ended. Tied.');
end

end

function updateCountdown(tobj, tevent, scr)
scr.setMainText(6-tobj.TasksExecuted);
end

function ret = cmpBtns(btn1, btn2)
ret = sum(btn1 == btn2) == 4;
end

function ret = cmp2Btns(btn1, btn2)
ret = sum(btn1 == btn2) == 2;
end