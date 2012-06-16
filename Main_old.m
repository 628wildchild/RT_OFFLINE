classdef Main
    %MAIN The app implements the scheme that asks the patient to press down 
    %  buttons as soon as he/she makes the decision. It counts from 5 - 1 then 
    %  GO-GO-GO. Patient can play with either computer or human
    
    properties
        player          = 0;            % play with computer (0) or human (1)
        patName         = 'Patient';    % patient name
        expName         = 'Uri';        % experimenter name
        initialMoney    = 5;            % initial endowment
        rounds          = 5;            % rounds
        
        recDecisionTime = ones(1, 1) * -2;
        recPatientChoice = ones(1, 1) * -2;
        recComputerChoice = ones(1, 1) * -2;
        recWinner = ones(1, 1) * -2;
        
        patMoney = 5;
        expMoney = 5;
        
        
    end
    
    properties (Access = private)
        res;
        scr;
        j;
    end
    
    methods
        function obj = Main()
            rng;
            
            obj.res = RespBox;
            obj.scr = Screen;
            obj.scr.initiate(obj.patName,obj.expName,obj.initialMoney);
            obj.scr.setMainText('Please put your hands down to start');
            if (obj.player)
                obj.res.setVal([1 0 1 0 0 1 0 1]);
                obj.res.monitorTargetWait([1 1 1 1]);
                obj.res.clearVal();
            else
                obj.res.setVal([1 0 1 0 0 0 0 0]);
                obj.res.monitorTargetWait([1 1 0 0]);
                obj.res.clearVal();
            end
            obj.scr.setMainText('Lift hands when ready');
            obj.res.monitorTargetWait([0 0 0 0]);
            obj.j = 1;
            if (obj.player)
                for i = 1:obj.rounds
                    obj.playWithHuman();
                end
            else
                for i = 1:obj.rounds
                    obj.playWithCmp();
                    pause(1);
                    obj.scr.setMainText('Lift both hands');
                    obj.res.monitorTargetWait([0 0 0 0]);
                end
                if obj.patMoney > obj.expMoney
                    obj.scr.setMainText(['Final winner is ', obj.patName]);
                elseif obj.patMoney < obj.expMoney
                    obj.scr.setMainText(['Final winner is ', obj.expName]);
                else
                    obj.scr.setMainText('Ties');
                end
            end
            stop(timerfindall);
        end
        
        function playWithCmp(obj)
            obj.res.setVal([1 0 1 0 1 0 1 0]);
            t = timer('StartDelay', 0, 'Period', 1, 'TasksToExecute', 5, ...
                'ExecutionMode', 'fixedRate');
            t.TimerFcn = {@updateCountdown, obj};
            start(t);
            tic;
            obj.res.monitorTargetWaitTime([1 1 0 0], 5);
            obj.res.setVal([0 0 0 0 0 0 0 0]);
            function updateCountdown(tobj, tevent, oobj)
                oobj.scr.setMainText(6-tobj.TasksExecuted);
            end
            obj.recDecisionTime(obj.j) = toc;
            ret = obj.res.monitorChangeWaitTime(5-toc);
            if (sum(ret == [-1 -1 -1 -1]) ~= 4)
                obj.scr.setMainText('Lifted too early?');
                obj.patMoney = obj.patMoney - .1;
                obj.scr.setMoney(1, obj.patMoney);
                return;
            end
            delete(t);
            if (sum(obj.res.getVal~=[1 1 0 0]) > 0)
                obj.scr.setMainText('Not put down?');
                obj.patMoney = obj.patMoney - .1;
                obj.scr.setMoney(1, obj.patMoney);
                return;
            end
            obj.scr.setMainText('GO-GO-GO');
            choice = obj.res.monitorChangeWaitTime(0.5);

            if (sum(choice==[1 0 0 0]) == 4)
                obj.recPatientChoice(obj.j) = 0;
                obj.scr.setP1Text('X  O');
            elseif (sum(choice==[0 1 0 0]) == 4)
                obj.recPatientChoice(obj.j) = 1;
                obj.scr.setP1Text('O  X');
            elseif (sum(choice==[-1 -1 -1 -1]) == 4)
                obj.recPatientChoice(obj.j) = -1;
                obj.scr.setMainText('Not lifting your hand?');
                obj.patMoney = obj.patMoney - .1;
                obj.scr.setMoney(1, obj.patMoney);
                return;
            else 
                obj.recPatientChoice(obj.j) = -1;
                obj.scr.setMainText('Lift both hands?');
                obj.patMoney = obj.patMoney - .1;
                obj.scr.setMoney(1, obj.patMoney);
                return;
            end
            
            obj.recComputerChoice(obj.j) = obj.decideComputer();
            
            if (obj.recPatientChoice(obj.j) == obj.recComputerChoice(obj.j))
                obj.scr.setMainText(sprintf('%s wins', obj.patName));
                obj.recWinner(obj.j) = 0;
                obj.patMoney = obj.patMoney + .1;
                obj.expMoney = obj.expMoney - .1;
                obj.scr.setMoney(1, obj.patMoney);
                obj.scr.setMoney(2, obj.expMoney);
            else 
                obj.scr.setMainText(sprintf('%s wins', obj.expName));
                obj.recWinner(obj.j) = 1;
                obj.patMoney = obj.patMoney - .1;
                obj.expMoney = obj.expMoney + .1;
                obj.scr.setMoney(1, obj.patMoney);
                obj.scr.setMoney(2, obj.expMoney);
            end
            
            obj.j = obj.j + 1;
        end
        
        function playWithHuman(obj)
            
        end
        
        function res = decideComputer(obj)
            res = round(rand());
        end
        
    end
    
end

