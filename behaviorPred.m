% -------------------------------------------------------------------------
function [r_l, conf_marg] = behaviorPred (new_entry)
% Based on player-1's history of pressing and winning (held in
% 'press1_hist') predict her or his next press. 'r_l' is 0 for right and 1
% for left. 'conf_marg' is the amount of evidence towards left (if
% negative) or right (if positive)

persistent press1_hist;
press1_hist = [press1_hist, new_entry-1];

persistent counters;
if (isempty(counters) || ...
    (ischar(press1_hist)&&strcmpi(press1_hist,'reset')))
    r_l = round(rand())+1;
    conf_marg = 0;
    press1_hist = [];
    counters=zeros(4,2); return;
end

press1_hist=press1_hist(press1_hist>0); % Ignore error trials
if (length(press1_hist)<2)
    no_pred=true;
else
    % Update counters
    no_pred=false;
    % Index should be 1 for R_{n-2}->R_{n-1}|W, 2 for R_{n-2}->R_{n-1}|~W,
    % 3 for L_{n-2}->R_{n-1}|W and 4 for L_{n-2}->R_{n-1}|~W
%     ind=(press1_hist(end-1)>2)*2+2-(mod(press1_hist(end-1),2)==1);
    counters(press1_hist(end-1),:)=counters(press1_hist(end-1),:)+...
        [(press1_hist(end)<3) 1];
end
if (~no_pred)
    f=counters(press1_hist(end),1)/counters(press1_hist(end),2);
    r_l=(f<.5); no_pred=(f==.5); 
%     if (press1_hist(end-1)>2), r_l=1-r_l; end
%     r_l=sign(c(1)/c(2)); if (press1_hist(end-1)<3), r_l=-r_l; end
%     no_pred=(abs(r_l)~=1); r_l=(1+r_l)/2;
end
if (no_pred)
    % Try seeling a simple left-right pattern (converting press1_hist into
    % a right=0, left=1 series)
    r_l=pattern_pred(press1_hist>2);
end
r_l = ~r_l + 1;
conf_marg=0;
end

% -------------------------------------------------------------------------
function [r_l, conf_marg] = pattern_pred (series)
% Given a binary series look for patterns in it that would predict the next
% bit. Here right is 0 and left is 1

max_back=20; 
if (isempty(series))
    no_pred=true; % true when there is equal evidence for left and right
else
    % Convert into a string to use the 'strfind' command that locates
    % patterns in strings
    str=char(double('a')+series); str_len=length(str);
    % Now look for a pattern 1 to 'max_back' characters backwards and for
    % each length find how many times the player chose left and right (and
    % erred) following that pattern, and store it in 'l' and 'r',
    % respectively. 
    n=min(str_len-1,max_back);
    choice=NaN(n,2);
    for k=1:n
        i=strfind(str,str(end-k+1:end)); i(end)=[];
%         if (~isempty(i)&&(i(end)+k-1==str_len))
%             i=i(1:end-1);
%         end
        if (isempty(i))
            choice(k,:)=zeros(1,size(choice,2));
        else
            s=str(i+k)-'a';
            choice(k,:)=hist(s,[0,1]);
        end
    end
    % Among all the left-right distributions of the patterns we searched,
    % we find the one most deviating from 50-50% (according to its
    % binomial cummulative distribution funcion) and predict using it. If
    % the best prediction is too close to 50-50% predict at random.
    [conf_marg,ind]=...
        min(1-binocdf(max(choice,[],2)-1,sum(choice,2),.5));
    no_pred=(isempty(conf_marg)||(conf_marg>=0.5)); 
    r_l=choice(ind,2)>choice(ind,1);
end
if (no_pred), r_l=round(rand); conf_marg=inf; end
end