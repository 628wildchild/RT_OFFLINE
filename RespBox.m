classdef RespBox
    %RESPBOX Response box controller
    %   getVal: get the value; setVal(value): set the value
    
    properties (Access = private)
        d_in;
        d_out;
        lines_in;
        lines_out;
    end
    
    methods
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
        
        function btns = getVal(obj)
            btns=~getvalue(obj.d_in.Line(obj.lines_in));
        end
        
        function setVal(obj, val)
            putvalue(obj.d_out.Line(obj.lines_out), val);
        end
        
        function clearVal(obj)
            putvalue(obj.d_out.Line(obj.lines_out), [0 0 0 0 0 0 0 0]);
        end
        
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
        
        function val = monitorChangeWait(obj)
            curVal = obj.getVal();
            while sum(obj.getVal ~= curVal)==0
            end
            val = obj.getVal;
        end
        
        function val = monitorChangeWaitTime(obj, time) 
            curVal = obj.getVal();
            tic;
            while toc <= time
                if sum(curVal ~= obj.getVal()) > 0 
                    val  = obj.getVal();
                    return;
                end
            end
            val = [-1 -1 -1 -1];
        end
        
        
        function monitorTarget(obj, tVal, callbackFunc)
            t = timer('StartDelay', 0, 'Period', 0.01, 'TasksToExecute', Inf, ...
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
        
        function val = monitorTargetWait(obj, tVal)
            tic;
            while sum(obj.getVal == tVal)~=4
            end
            val = obj.getVal;
        end        

        function val = monitorTargetWaitTime(obj, tVal, tTime)
            tic;
            while sum(obj.getVal == tVal)~=4
                if (toc >= tTime); break; end
            end
            val = obj.getVal;
        end
        
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
    
end

