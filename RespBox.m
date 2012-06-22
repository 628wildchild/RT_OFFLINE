classdef RespBox
    %RESPBOX Response box controller
    %   getVal: get the value; setVal(value): set the value
    
    properties (Access = private)
        d_in;
        d_out;
        lines_in;
        lines_out;
        pauseT = 0.005;
    end
    
    methods
        %% constructor - initilize response box
        function obj = RespBox()
            dio_info=daqhwinfo('nidaq');
            if (isempty(dio_info.BoardNames))
                error('No response box connected. Aborting.');
            end
            fprintf('Adding response box: %s\n',dio_info.BoardNames{1});
            obj.d_in=digitalio('nidaq',dio_info.InstalledBoardIds{1});
            obj.d_out=digitalio('nidaq',dio_info.InstalledBoardIds{1});
            
            obj.lines_in=1:4;
            obj.lines_out=1:8;
            
            addline(obj.d_in,obj.lines_in-1,0,'In');
            addline(obj.d_out,obj.lines_out-1,1,'Out');
        end
        
        %% primitive functions, get value and set value
        function btns = getVal(obj)
            btns=~getvalue(obj.d_in.Line(obj.lines_in));
        end
        
        function setVal(obj, val)
            putvalue(obj.d_out.Line(obj.lines_out), val);
        end
        
        function clearVal(obj)
            putvalue(obj.d_out.Line(obj.lines_out), [0 0 0 0 0 0 0 0]);
        end
        
        %% high level functions [C = callback, W = wait] 
        
        % [W] monitor changes of the response box, call back when a change
        % occured. return changed value. 
        function val = monitorChangeWait(obj)
            curVal = obj.getVal();
            while sum(obj.getVal ~= curVal)==0
                pause(obj.pauseT);
            end
            val = obj.getVal;
        end

        % [W] return when changeing to a specific value. return the
        % specific value
        function val = monitorTargetWait(obj, tVal)
            rec = 0;
            val = obj.getVal;
            while sum(val == tVal)~=4
                rec = exitSeq(rec, val);
                pause(obj.pauseT);
                val = obj.getVal;
            end
        end        
        
        % [W] monitor changes of the responsce box for a specific time
        % (sec). return changed value, or [-1 -1 -1 -1] if timeout 
        function val = monitorChangeWaitTime(obj, time) 
            rec = 0;
            curVal = obj.getVal();
            tic;
            while toc <= time
                rec = exitSeq(rec, obj.getVal());
                pause(obj.pauseT);
                if sum(curVal ~= obj.getVal()) > 0 
                    val  = obj.getVal();
                    return;
                end
            end
            val = [-1 -1 -1 -1];
        end
        
        % [W] monitor two targets together and wait, or timeout. The
        % timeout returns [-1 -1 -1 -1], otherwise return the specific
        % value
        function val = monitor2TargetsWaitTime(obj, tVal1, tVal2, tTime)
            rec = 0;
            tic;
            v = obj.getVal;
            while sum(v == tVal1)~=4 && sum(v == tVal2)~=4
                rec = exitSeq(rec, obj.getVal());
                pause(obj.pauseT);
                if (toc >= tTime)
                    val = [-1 -1 -1 -1];
                    return;
                end
            end
            val = v;
        end

        % [C] monitor changes of the response box, call back when a change
        % occured. 
        function monitorChange(obj, callbackFunc)
            t = timer('StartDelay', 0, 'Period', 0.01, 'TasksToExecute', Inf, ...
                'ExecutionMode', 'fixedRate');
            curVal = obj.getVal();
            t.TimerFcn = {@monitorVal, obj, callbackFunc, curVal, t};
            start(t);
            function monitorVal(obj, event, tobj, callbackFunc, curVal, t)
                if (sum(tobj.getVal() ~= curVal)>0)
                    stop(t);
                    delete(t);
                    callbackFunc(tobj.getVal());
                end
            end
        end
        
        % [C] callback when changing to a specific value. 
        function monitorTarget(obj, tVal, callbackFunc)
            t = timer('StartDelay', 0, 'Period', 0.1, 'TasksToExecute', Inf, ...
                'ExecutionMode', 'fixedRate');
            t.TimerFcn = {@monitorVal, obj, callbackFunc, tVal, t};
            start(t);
            function monitorVal(obj, event, tobj, callbackFunc, tVal, t)
                if (sum(tobj.getVal() == tVal)==4)
                    stop(t);
                    delete(t);
                    callbackFunc(0);
                end
            end
        end

        % [C] return when changing tp a specific value, or timeout. The
        % timeout returns [-1 -1 -1 -1]; otherwise return the specific
        % value
        function val = monitorTargetWaitTime(obj, tVal, tTime)
            tic;
            while sum(obj.getVal == tVal)~=4
                pause(obj.pauseT);
                if (toc >= tTime)
                    val = [-1 -1 -1 -1];
                    return;
                end
            end
            val = obj.getVal;
        end      

        % [C] monitor both target and change. (do not use becuase there is
        % a bug) 
        function monitorTargetChange(obj, tVal, callbackFunc)
            t = timer('StartDelay', 0, 'Period', 0.01, 'TasksToExecute', Inf, ...
                'ExecutionMode', 'fixedRate');
            curVal = obj.getVal();
            t.TimerFcn = {@monitorVal, obj, callbackFunc, tVal, curVal, t};
            start(t);
            function monitorVal(obj, event, tobj, callbackFunc, tVal, curVal, t)
                if (sum(tobj.getVal() == tVal)==4)
                    stop(t);
                    delete(t);
                    callbackFunc(-1);
                elseif (sum(tobj.getVal() ~= curVal)>0)
                    stop(t);
                    delete(t);
                    callbackFunc(bi2de(tobj.getVal()));
                end
            end
        end
        
    end
    
    methods (Access = private)
        function output = exitSeq(input, value)
            output = input;
            if input == 0 && sum(value == [0 0 0 1]) == 4
                output = 1; return;
            elseif input == 1 && sum(value == [0 0 1 0]) == 4
                output = 2; return;
            elseif input == 2 && sum(value == [0 1 0 0]) == 4
                output = 3; return;
            elseif input == 3 && sum(value == [1 0 0 0]) == 4
                error('Forced exit');
            end
        end
    end
    
end

