classdef Screen
    %SCREEN Create and maintain GUI
    %   
    
    properties
        guihandle;
    end
    
    methods
        function obj = Screen()
            obj.guihandle = guihandles(gui2);
            set(obj.guihandle.maintext, 'String', 'WELCOME :)');
            drawnow();
        end
        
        function initiate(obj, name1, name2, initialMoney)
            set(obj.guihandle.name1, 'String', name1);
            set(obj.guihandle.name2, 'String', name2);
            obj.setMoney(0, initialMoney);
        end
        
        function setMoney(obj, player, amount)
            if player == 1
                set(obj.guihandle.money1, 'String', '');
                pause(0.2);
                set(obj.guihandle.money1, 'String', ['$',num2str(amount,'%.2f')]);
                drawnow();
            elseif player == 2
                set(obj.guihandle.money2, 'String', '');
                pause(0.2);
                set(obj.guihandle.money2, 'String', ['$',num2str(amount,'%.2f')]);
                drawnow();
            else
                set(obj.guihandle.money1, 'String', '');
                set(obj.guihandle.money2, 'String', '');
                pause(0.2);
                set(obj.guihandle.money1, 'String', ['$',num2str(amount,'%.2f')]);
                set(obj.guihandle.money2, 'String', ['$',num2str(amount,'%.2f')]);
                drawnow();
            end
        end
        
        function setMainText(obj, str)
            set(obj.guihandle.maintext, 'String', str);
            drawnow();
        end
        
        function setP1Text(obj, str)
            set(obj.guihandle.main1, 'String', str);
            drawnow();
        end
        
        function setP2Text(obj, str)
            set(obj.guihandle.main2, 'String', str);
            drawnow();
        end
        
        function setStatus(obj, str)
            set(obj.guihandle.status, 'String', str);
            drawnow();
        end
    end
    
end

