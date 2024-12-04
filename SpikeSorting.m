if load_data
    
    Spikes= mspikes;
    
    
    if size(Spikes{1,1}(:,:), 1) < 10*perplexity
        message = sprintf('Spike number must be more than 10*Perplexity');
        close(f)
        return
    end
    
    
    Y = tsne(Spikes{1,1}, 'NumDimensions',3,'Distance','euclidean','Perplexity',perplexity);
    Y_final{1,1}=Y;
    epsilon=app.epsilonEditField.Value;
    MinPts=app.MinPtsEditField.Value;
    IDX=DBSCAN(Y,epsilon,MinPts);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:max(IDX)
        if sum(IDX==i)<30
            IDX(IDX==i)=0;
        end
    end
    
    for i=1:max(IDX)
        if  isempty(find(IDX==i, 1))
            e=min(IDX(find(IDX>i)));
            if e==max(IDX)
                IDX(IDX==e)=i;
                break
            end
            IDX(IDX==e)=i;
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for kkk=0:max(IDX)
        for jjj=0:max(IDX)
            cont1=find(IDX==kkk);
            cont2=find(IDX==jjj);
            YYY=Y_final{1,1};
            Y_cont1=mean(YYY(cont1,:),1);
            Y_cont2=mean(YYY(cont2,:),1);
            PsC1 (kkk+1,jjj+1)  = pdist( [Y_cont1;Y_cont2] );
        end
    end
    
    PsC1 =PsC1 /max(max(PsC1 )) ;
    
    for kkk=0:max(IDX)
        for jjj=kkk+1:max(IDX)
            if PsC1(kkk+1,jjj+1)< 0.1263
                IDX(IDX == jjj)=kkk;
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for i=1:max(IDX)
        if sum(IDX==i)<30
            IDX(IDX==i)=0;
        end
    end
    
    for i=1:max(IDX)
        if  isempty(find(IDX==i, 1))
            e=min(IDX(find(IDX>i)));
            if e==max(IDX)
                IDX(IDX==e)=i;
                break
            end
            IDX(IDX==e)=i;
            
        end
    end
    M=min(IDX);
    if M>0
        IDX=IDX-M;
    end
    %                 IDX_NADIAN{1,1}=IDX';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%  Plot UNITS
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    k=max(IDX);
    
    h=figure('units','pixels','resize', 'off','outerposition',[0 0 1400 1000]);
    drawnow;
    pause(0.01)
    number=0;
    app.allspikes=[];
    
    
    %%%%%%   find NOISE 
    percent_refractory1=0;
    for ii=0:k
        
        
        Xi=Spikes{1,1}(IDX==i,:);
        XXi=Y_final{1,1}(IDX==i,:);
        if ~app.LoadSpikes
            TTi=app.Time_Stamp{1,1}(:,IDX==i)';
        end
        if ~isempty(TTi)
            for s=1:size(Xi,1)
                
                if ~app.LoadSpikes
                    app.allspikes.Time_Stamp{1,i+1}(s,:)=TTi(s,:);
                end
                
                
            end
            
            if ~app.LoadSpikes
                %                         if ~isempty( app.allspikes)
                Yi=sort(app.allspikes.Time_Stamp{1,ii+1});
                Hist_time=diff(Yi)/app.SamplingrateEditField.Value;
                HIST_Refractory=Hist_time(Hist_time<(app.MinimumrefractoryperiodmsEditField.Value/1000));
                percent_refractory1(ii+1)=100*size(HIST_Refractory,1)/size(Yi,1)/10000;
                %                         end
            end
        end
    end
    
    
    [~ ,row_max_percent_refractory]=find(percent_refractory1==max(percent_refractory1));
    
    if max(percent_refractory1)>.5
        IDX2=IDX;
        IDX2(IDX==row_max_percent_refractory-1)=0;
        IDX2(IDX==0)=row_max_percent_refractory-1;
        IDX=IDX2;
        
        
    else
        
        
        IDX=IDX+1;
        
        
    end
   
    k=max(IDX);                
    Color=hsv(k+1);
    
    %%%%%%%%%%%%%
    
    for i=0:k
                sh2(i+1)=subplot(ceil((k+1)/2),4,(2*i+1),'Units', 'pixels');
                sh= sh2(i+1);
                hold on
                Xi=Spikes{1,1}(IDX==i,:);
                XXi=Y_final{1,1}(IDX==i,:);
                    if ~app.LoadSpikes
                        TTi=app.Time_Stamp{1,1}(:,IDX==i)';
                    end
                    if ~isempty(TTi)
                        for s=1:size(Xi,1)
                            number=number+1;
                            plot(Xi(s,:),'Color',Color(i+1,:),'ButtonDownFcn', @change_Spikes, 'userdata', s);
                            app.allspikes.Spike{1,i+1}(s,:)=Xi(s,:);
                            app.allspikes.Position{1,i+1}(s,:)=sh.Position;
                            app.allspikes.Index{1,i+1}(s,:)=i;
                            app.allspikes.userdata{1,i+1}(s,:)=s;
                            app.allspikes.tsne{1,i+1}(s,:)=XXi(s,:);
                            if ~app.LoadSpikes
                                app.allspikes.Time_Stamp{1,i+1}(s,:)=TTi(s,:);
                            end
                            
                            
                        end
                        if i==0
                            legend({'Noise (Unit #0)'},'FontSize',8,'AutoUpdate','off');
                        else
                            legend({['UNIT #', num2str(i)]},'FontSize',8,'AutoUpdate','off');
                            
                        end
                    else
                            app.allspikes.Position{1,i+1}(1,:)=sh.Position;
                    end
        %                 else
        %                     legend('Noise');
        %                 end
                    if ~app.LoadSpikes
                        sh3(i+1)=subplot(ceil((k+1)/2),4,(2*i+1)+1,'Units', 'pixels');
                        if ~isempty(TTi)
                            Yi=sort(app.allspikes.Time_Stamp{1,i+1});
                            
                            Hist_time=diff(Yi)/app.SamplingrateEditField.Value;
                            size_bin=app.HistogramBinsizeEditField.Value;
                            %                         [aaa bbb]=hist(Hist_time,size_bin);
                            hist(Hist_time,size_bin)
                            
                            HIST_Refractory=Hist_time(Hist_time<(app.MinimumrefractoryperiodmsEditField.Value/1000));
                            
                            %                         size(Yi,1)
                            %                         size(HIST_Refractory)
                            percent_refractory=100*size(HIST_Refractory,1)/size(Yi,1)/10000;
                            title(['About ',num2str(percent_refractory),' % of ' ,num2str(size(Yi,1)) ,' spikes < ',num2str(app.MinimumrefractoryperiodmsEditField.Value) ,'ms'] ,'FontSize',8)
                        end
                    end

        
    end
    pause(0.01)
    drawnow;
    
    for i=0:k

        uicontrol(h , 'string', '', 'Style','pushbutton', ...
            'position', [sh2(i+1).Position(1) sh2(i+1).Position(2) 20 20], 'Units', 'normalized',...
            'Backgroundcolor', 'r', ...
            'Callback', @button_pushed, 'UserData', sh2(i+1));
        
        
        uicontrol(h , 'string', '', 'style','edit', ...
            'position', [sh2(i+1).Position(1)+20 sh2(i+1).Position(2) 20 20], 'Units', 'normalized',...
            'foregroundcolor', 'k', ...
            'Callback', @string_get, 'UserData', sh2(i+1));
        
    end
    
    
    
    %%%%%%ADD  app.allspikes to handle

    myhandles = guihandles(h);
    % Add some additional data as a new field called numberOfErrors
    myhandles.allspikes = app.allspikes;
    % Save the structure
    guidata(h,myhandles)

    %%%%%subplot tsne
    
    sh1=figure(2);
    

    for i=0:k
        XXi=app.allspikes.tsne{1,i+1}(:,:);

        Style = 'o';
        MarkerSize = 6;

        if ~isempty(XXi)
            plot3(XXi(:,1),XXi(:,2),XXi(:,3),Style,'MarkerSize',MarkerSize,'Color',Color(i+1,:));
            hold on;
            grid on;
        end
    end

    view(3)

    pause(0.01);

    close(f);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% PLOT SPIKES in APP based on Clustering
    app.drawn_spikes = true;
    
    
    cla(app.UIAxes_2,'reset')
    app.UIAxes_2.YAxisLocation='right';
    hold(app.UIAxes_2,'on');
    
    range=40000;
    %             app.SlidertimeChange.Limits=[1,size(app.mdata{1,1},2)-1-range];
    time_start=ceil(app.SlidertimeChange.Value);
    time_end=time_start+range;
    
    if numel(app.SpikesplotmodeDropDown.Value)== numel('All Spikes')
        
        for i=0:k
            Spikes_Clustered=app.allspikes.Spike{1,i+1};
            plot(app.UIAxes_2,Spikes_Clustered','Color',Color(i+1,:))
            app.NumbersofSpikesEditField.Value=size(mspikes{1,1},1);
        end
    elseif   ~app.LoadSpikes 
        
        
        SUM_TIMELIM=0;
        for i=0:k
            timeLim=find((app.allspikes.Time_Stamp{1,i+1}< time_end) & (app.allspikes.Time_Stamp{1,i+1}>time_start));
            if timeLim
                inverse_Spike=app.allspikes.Spike{1,i+1}';
                for j=1:size(timeLim,1)
                    
                    plot(app.UIAxes_2,inverse_Spike(:,j),'Color',Color(i+1,:));
                end
            end
            SUM_TIMELIM=size(timeLim,1)+SUM_TIMELIM;
        end
        app.NumbersofSpikesEditField.Value=SUM_TIMELIM;
        
    end
    
    app.UIAxes_2.YLim(2)=ceil(  app.UIAxes_2.YLim(2));
    app.UIAxes_2.YLim(1)=round(  app.UIAxes_2.YLim(1));
    
    
    
    %                 app.size_x=app.UIAxes_2.XLim(2);
    app.LowerlimitSlider.Limits=[0,round(100*(app.UIAxes_2.XLim(2)/2)/100)];
    app.UpperlimitSlider.Limits=[round(100*(app.UIAxes_2.XLim(2)/2)/100),ceil(100*(app.UIAxes_2.XLim(2))/100)];
    
    
    if  size(app.allspikes.Spike{1,1},2)==0
        app.UpperlimitSlider.Value=41;
    else
    app.UpperlimitSlider.Value=(size(app.allspikes.Spike{1,1},2)) ;
    end
    app.LowerlimitSlider.Value=1;
    
    app.size_spike=app.UpperlimitSlider.Value;
    
    app.upperlimit_value= app.UpperlimitSlider.Value;
    app.lowerlimit_value=app.LowerlimitSlider.Value;
    
    plot(app.UIAxes_2,ones(1,(app.UIAxes_2.YLim(2)-app.UIAxes_2.YLim(1)+1)).*((round(100*(app.lowerlimit_value)/100))),app.UIAxes_2.YLim(1):app.UIAxes_2.YLim(2),'red');
    plot(app.UIAxes_2,ones(1,(app.UIAxes_2.YLim(2)-app.UIAxes_2.YLim(1)+1)).*((round(100*(app.upperlimit_value)/100))),app.UIAxes_2.YLim(1):app.UIAxes_2.YLim(2),'red');
    
    %            figure
    
    hold(app.UIAxes_2,'off');
    %             dbstop if error
    %%%% plot SPIKE TRAIN
    if   ~app.LoadSpikes
    cla(app.UIAxes_3)
    app.UIAxes_3.XLim=app.UIAxes.XLim;
    app.UIAxes_3.YLim=[0,1];
    hold(app.UIAxes_3,'on');
    for i=0:k
        timeLim=find((app.allspikes.Time_Stamp{1,i+1}< time_end) & (app.allspikes.Time_Stamp{1,i+1}>time_start));
        if timeLim
            for j=1:size(timeLim,1)
                plot(app.UIAxes_3,[app.allspikes.Time_Stamp{1,i+1}(timeLim(j)) app.allspikes.Time_Stamp{1,i+1}(timeLim(j))]/app.SamplingrateEditField.Value,[0 1],'Color',Color(i+1,:)) ;
            end
        end
    end
    hold(app.UIAxes_3,'off');
    
    end

    load_data = true;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
else
    return
end

function change_Spikes(hobject, eventdata)
    j =get(gcbo, 'userdata');
    myhandles = guidata(hobject.Parent.Parent);
    allspikes_2=myhandles.allspikes;
    for k=1:size(allspikes_2.Index,2)
        if sum(hobject.Parent.Position==allspikes_2.Position{1,k}(1,:))==4
            allspikes_2.Index{1,k}(j,:)=[];
            %                         allspikes_2.Position{1,k}(j,:)=[];
            allspikes_2.Spike{1,k}(j,:)=[];
            %                         allspikes_2.userdata{1,k}(j,:)=[];
            allspikes_2.tsne{1,k}(j,:)=[];
            if ~app.LoadSpikes
                allspikes_2.Time_Stamp{1,k}(j,:)=[];
            end
        end
    end
    myhandles.allspikes=allspikes_2;
    
    guidata(hobject.Parent.Parent,myhandles)
    delete(gcbo)
    app.allspikes=allspikes_2;
end

function button_pushed(hobject, eventdata)
    sh = hobject.UserData;
    hold(sh,'on')
    YLIMY=sh.YLim;
    XLIMX=sh.XLim;
    [x1,y1] = ginput(1);
    hold(gca,'on')
    obj1 = plot(x1, y1, 'r*');
    [x2,y2] = ginput(1);
    hold(gca,'on')
    obj2 = plot(x2, y2, 'r*');
    obj3 = plot([x1 x2], [y1 y2], 'r', 'linewidth', 3);
    if sum(obj2.Parent.Position == sh.Position) == 4 &&  sum(obj1.Parent.Position == sh.Position) == 4
        allspikes_2=myhandles.allspikes;
        allspikes_3=Delete_Spikes([x1 x2], [y1 y2], sh,allspikes_2);
        myhandles.allspikes=allspikes_3;
        guidata(hobject,myhandles)
%                     drawnow;
%                     pause(0.02);
        app.allspikes=allspikes_3;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% PLOT SPIKES in APP based on Clustering
        app.drawn_spikes = true;
        Color=hsv(k+1);
        cla(app.UIAxes_2,'reset')
        app.UIAxes_2.YAxisLocation='right';
        hold(app.UIAxes_2,'on');
        range=40000;
        %             app.SlidertimeChange.Limits=[1,size(app.mdata{1,1},2)-1-range];
        time_start=ceil(app.SlidertimeChange.Value);
        time_end=time_start+range;
         drawnow nocallbacks
        if numel(app.SpikesplotmodeDropDown.Value)== numel('All Spikes')
            
            for i=0:k
                Spikes_Clustered=app.allspikes.Spike{1,i+1};
                plot(app.UIAxes_2,Spikes_Clustered','Color',Color(i+1,:))
                app.NumbersofSpikesEditField.Value=size(mspikes{1,1},1);
            end
        elseif   ~app.LoadSpikes
            SUM_TIMELIM=0;
            for i=0:k
                timeLim=find((app.allspikes.Time_Stamp{1,i+1}< time_end) & (app.allspikes.Time_Stamp{1,i+1}>time_start));
                if timeLim
                    inverse_Spike=app.allspikes.Spike{1,i+1}';
                    for j=1:size(timeLim,1)
                        
                        plot(app.UIAxes_2,inverse_Spike(:,j),'Color',Color(i+1,:));
                    end
                end
                SUM_TIMELIM=size(timeLim,1)+SUM_TIMELIM;
            end
            app.NumbersofSpikesEditField.Value=SUM_TIMELIM;
            
        end
        
        app.UIAxes_2.YLim(2)=ceil(  app.UIAxes_2.YLim(2));
        app.UIAxes_2.YLim(1)=round(  app.UIAxes_2.YLim(1));
        
        app.LowerlimitSlider.Limits=[0,round(100*(app.UIAxes_2.XLim(2)/2)/100)];
        app.UpperlimitSlider.Limits=[round(100*(app.UIAxes_2.XLim(2)/2)/100),round(100*(app.UIAxes_2.XLim(2))/100)];
        
        app.UpperlimitSlider.Value=size(app.allspikes.Spike{1,1},2) ;
        app.LowerlimitSlider.Value=1;
        
        app.size_spike=app.UpperlimitSlider.Value;
        
        app.upperlimit_value= app.UpperlimitSlider.Value;
        app.lowerlimit_value=app.LowerlimitSlider.Value;
        
        plot(app.UIAxes_2,ones(1,(app.UIAxes_2.YLim(2)-app.UIAxes_2.YLim(1)+1)).*((round(100*(app.lowerlimit_value)/100))),app.UIAxes_2.YLim(1):app.UIAxes_2.YLim(2),'red');
        plot(app.UIAxes_2,ones(1,(app.UIAxes_2.YLim(2)-app.UIAxes_2.YLim(1)+1)).*((round(100*(app.upperlimit_value)/100))),app.UIAxes_2.YLim(1):app.UIAxes_2.YLim(2),'red');
        
        hold(app.UIAxes_2,'off');
        %%%% plot SPIKE TRAIN
        if   ~app.LoadSpikes
            cla(app.UIAxes_3)
            app.UIAxes_3.XLim=app.UIAxes.XLim;
            app.UIAxes_3.YLim=[0,1];
            hold(app.UIAxes_3,'on');
            for i=0:k
                timeLim=find((app.allspikes.Time_Stamp{1,i+1}< time_end) & (app.allspikes.Time_Stamp{1,i+1}>time_start));
                if timeLim
                    for j=1:size(timeLim,1)
                        plot(app.UIAxes_3,[app.allspikes.Time_Stamp{1,i+1}(timeLim(j)) app.allspikes.Time_Stamp{1,i+1}(timeLim(j))]/app.SamplingrateEditField.Value,[0 1],'Color',Color(i+1,:)) ;
                    end
                end
            end
            hold(app.UIAxes_3,'off');
            
            
        end
         drawnow
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        delete(obj1);
        delete(obj2);
        delete(obj3);
    
    sh.YLim=YLIMY;
    sh.XLim=XLIMX;
    close(ff)
end


function allspikes_2=Delete_Spikes(X, Y, handle,allspikes_2)
    
    for n=1:size(allspikes_2.Index,2)
        if (~isempty(allspikes_2.Position{1,n})) && (~isempty(allspikes_2.Spike{1,n})) && sum(handle.Position==allspikes_2.Position{1,n}(1,:))==4
            
            Y_spike=allspikes_2.Spike{1,n};
            Y_spike(:,end+1)= nan;
            X_spike=repmat(1:size(Y_spike,2)-1,size(Y_spike,1),1);
            X_spike(:,end+1)=nan;
            
            
            INDEX_spike=(1:size(Y_spike,1))';
            INDEX_spike=repmat(INDEX_spike,1,size(Y_spike,2)-1);
                             INDEX_spike(:,end+1)=nan;

            Y_spike=reshape(Y_spike',1,size(Y_spike,2)*size(Y_spike,1));
            X_spike=reshape(X_spike',1,size(Y_spike,2)*size(Y_spike,1));
            INDEX_spike=reshape(INDEX_spike',1,size(Y_spike,2)*size(Y_spike,1));
           
            
            
            [~,~,ii]=polyxpoly(X,Y,X_spike,Y_spike);
            
            ro=INDEX_spike(ii);
            ro=ro(:,2)';
            allspikes_2.Index{1,n}(ro,:)=[];
            allspikes_2.Spike{1,n}(ro,:)=[];
            allspikes_2.tsne{1,n}(ro,:)=[];
            if ~app.LoadSpikes
                allspikes_2.Time_Stamp{1,n}(ro,:)=[];
            end
            break
        end
    end
   drawnow nocallbacks 
    k=size(allspikes_2.Spike,2)-1;
    cla(sh2(n),'reset')
    if   ~app.LoadSpikes
        cla(sh3(n),'reset')
    end
%                 cla(sh1.Children)
    Color=hsv(k+1);
    Xi= allspikes_2.Spike{1,n};
    hold(sh2(n),'on')
    for s=1:size(Xi,1)
        plot(sh2(n),Xi(s,:),'Color',Color(n,:),'ButtonDownFcn', @change_Spikes, 'userdata', s);
        
    end
    drawnow;
%                 pause(0.02);
    hold(sh2(n),'off')
    
    if size(sh2(n).Children)
        [sh2(n).Children(1:end).DisplayName]=deal('');
        sh2(n).Children(end).DisplayName=(['UNIT #', num2str(n)]);
        LEGEND=legend(sh2(n).Children(end).DisplayName);
        LEGEND.FontSize=8;
    end
    
    if ~app.LoadSpikes
        TTi=sort(allspikes_2.Time_Stamp{1,n});
        Hist_time=diff(TTi)/app.SamplingrateEditField.Value;
        size_bin=app.HistogramBinsizeEditField.Value;
        hist(sh3(n),Hist_time,size_bin)
        HIST_Refractory=Hist_time(Hist_time<(app.MinimumrefractoryperiodmsEditField.Value/1000));
        percent_refractory=100*size(HIST_Refractory,1)/size(TTi,1)/10000;
        
        
        title(sh3(n),['About ',num2str(percent_refractory),' % of ' ,num2str(size(TTi,1)) ,' spikes are < ',num2str(app.MinimumrefractoryperiodmsEditField.Value) ,'ms'] ,'FontSize',8)
    end
    drawnow;
    %pause(0.001);
    
    cla(sh1.Children)
    %cla(sh1)
   
    for i=0:k
        XXi=allspikes_2.tsne{1,i+1}(:,:);
        Style = 'o';
        MarkerSize = 6;
        if ~isempty(XXi)
            plot3(sh1.Children,XXi(:,1),XXi(:,2),XXi(:,3),Style,'MarkerSize',MarkerSize,'Color',Color(i+1,:));
            hold (sh1.Children,'on')
            grid(sh1.Children, 'on');

        end
        
    end
    drawnow;
%                 pause(0.001);
    hold (sh1.Children,'off')
%                  drawnow
end



function string_get(hobject, eventdata)
    Unit_Final=str2num(get(hobject,'String'))+1;
    sh = hobject.UserData;
    hold(sh,'on')
    YLIMY=sh.YLim;
    XLIMX=sh.XLim;
    [x1,y1] = ginput(1);
    hold(gca,'on')
    obj1 = plot(x1, y1, 'r*');

    [x2,y2] = ginput(1);
    hold(gca,'on')
    obj2 = plot(x2, y2, 'r*');
    obj3 = plot([x1 x2], [y1 y2], 'r', 'linewidth', 3);
    
    %                 YLIMY=sh.YLim;
    %                 XLIMX=sh.XLim;
    if sum(obj2.Parent.Position == sh.Position) == 4 &&  sum(obj1.Parent.Position == sh.Position) == 4
        
        %                     myhandles = guidata(hobject.Parent.Parent);
        allspikes_2=myhandles.allspikes;
        
        
        allspikes_3=Change_Units([x1 x2], [y1 y2], sh,allspikes_2,Unit_Final,myhandles);
        myhandles.allspikes=allspikes_3;
        guidata(hobject,myhandles)
%                     drawnow;
%                     pause(0.2);
        app.allspikes=[];
        app.allspikes=allspikes_3;
        %                 else
        %                     warning('bad bad')
    end
    
    
    sh.YLim=YLIMY;
    sh.XLim=XLIMX;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%% PLOT SPIKES in APP based on Clustering
    

    app.drawn_spikes = true;
     Color=hsv(k+1);
    cla(app.UIAxes_2,'reset')
    app.UIAxes_2.YAxisLocation='right';
    hold(app.UIAxes_2,'on');
    
     drawnow nocallbacks
    range=40000;
    %             app.SlidertimeChange.Limits=[1,size(app.mdata{1,1},2)-1-range];
    time_start=ceil(app.SlidertimeChange.Value);
    time_end=time_start+range;
    
    if numel(app.SpikesplotmodeDropDown.Value)== numel('All Spikes')
        
        for i=0:k
            Spikes_Clustered=app.allspikes.Spike{1,i+1};
            plot(app.UIAxes_2,Spikes_Clustered','Color',Color(i+1,:))
            app.NumbersofSpikesEditField.Value=size(mspikes{1,1},1);
        end
        drawnow;
        pause(0.001);
    elseif   ~app.LoadSpikes
        SUM_TIMELIM=0;
        for i=0:k
            timeLim=find((app.allspikes.Time_Stamp{1,i+1}< time_end) & (app.allspikes.Time_Stamp{1,i+1}>time_start));
            if timeLim
                inverse_Spike=app.allspikes.Spike{1,i+1}';
                for j=1:size(timeLim,1)
                    
                    plot(app.UIAxes_2,inverse_Spike(:,j),'Color',Color(i+1,:));
                end
            end
            SUM_TIMELIM=size(timeLim,1)+SUM_TIMELIM;
        end
        app.NumbersofSpikesEditField.Value=SUM_TIMELIM;
        drawnow;
%                     pause(0.001);
    end

    app.UIAxes_2.YLim(2)=ceil(  app.UIAxes_2.YLim(2));
    app.UIAxes_2.YLim(1)=round(  app.UIAxes_2.YLim(1));
    

    %                 app.size_x=app.UIAxes_2.XLim(2);
    app.LowerlimitSlider.Limits=[0,round(100*(app.UIAxes_2.XLim(2)/2)/100)];
    app.UpperlimitSlider.Limits=[round(100*(app.UIAxes_2.XLim(2)/2)/100),round(100*(app.UIAxes_2.XLim(2))/100)];

    
    app.UpperlimitSlider.Value=size(app.allspikes.Spike{1,1},2) ;
    app.LowerlimitSlider.Value=1;
    
    app.size_spike=app.UpperlimitSlider.Value;
    
    app.upperlimit_value= app.UpperlimitSlider.Value;
    app.lowerlimit_value=app.LowerlimitSlider.Value;
    
    plot(app.UIAxes_2,ones(1,(app.UIAxes_2.YLim(2)-app.UIAxes_2.YLim(1)+1)).*((round(100*(app.lowerlimit_value)/100))),app.UIAxes_2.YLim(1):app.UIAxes_2.YLim(2),'red');
    plot(app.UIAxes_2,ones(1,(app.UIAxes_2.YLim(2)-app.UIAxes_2.YLim(1)+1)).*((round(100*(app.upperlimit_value)/100))),app.UIAxes_2.YLim(1):app.UIAxes_2.YLim(2),'red');
    
    %            figure
    
    hold(app.UIAxes_2,'off');
    %             dbstop if error
    %%%% plot SPIKE TRAIN
    if   ~app.LoadSpikes
    cla(app.UIAxes_3)
    app.UIAxes_3.XLim=app.UIAxes.XLim;
    app.UIAxes_3.YLim=[0,1];
    hold(app.UIAxes_3,'on');
    for i=0:k
        timeLim=find((app.allspikes.Time_Stamp{1,i+1}< time_end) & (app.allspikes.Time_Stamp{1,i+1}>time_start));
        if timeLim
            for j=1:size(timeLim,1)
                plot(app.UIAxes_3,[app.allspikes.Time_Stamp{1,i+1}(timeLim(j)) app.allspikes.Time_Stamp{1,i+1}(timeLim(j))]/app.SamplingrateEditField.Value,[0 1],'Color',Color(i+1,:)) ;
            end
            drawnow;
            pause(0.001);
        end
    end
    hold(app.UIAxes_3,'off');
    end
    delete(obj1);
    delete(obj2);
    delete(obj3);
    
    drawnow
    close(ff)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


function allspikes_2=Change_Units(X, Y, handle,allspikes_2,Unit_Final,hobject)

    for n=1:size(allspikes_2.Index,2)
        if (~isempty(allspikes_2.Position{1,n})) && (~isempty(allspikes_2.Spike{1,n})) && sum(handle.Position==allspikes_2.Position{1,n}(1,:))==4
            
            Y_spike=allspikes_2.Spike{1,n};
            Y_spike(:,end+1)= nan;
            X_spike=repmat(1:size(Y_spike,2)-1,size(Y_spike,1),1);
            X_spike(:,end+1)=nan;
            
            
            INDEX_spike=(1:size(Y_spike,1))';
            INDEX_spike=repmat(INDEX_spike,1,size(Y_spike,2)-1);
            INDEX_spike(:,end+1)=nan;
            
            Y_spike=reshape(Y_spike',1,size(Y_spike,2)*size(Y_spike,1));
            X_spike=reshape(X_spike',1,size(Y_spike,2)*size(Y_spike,1));
            INDEX_spike=reshape(INDEX_spike',1,size(Y_spike,2)*size(Y_spike,1));
            
            
            
            [~,~,ii]=polyxpoly(X,Y,X_spike,Y_spike);
            ro=INDEX_spike(ii);
            ro=ro(:,2)';
            allspikes_2.Index{1,Unit_Final}=[allspikes_2.Index{1,Unit_Final};ones(size(ro,2),1)*(Unit_Final-1)];
            %                                             allspikes_2.Position{1,Unit_Final}=[allspikes_2.Position{1,Unit_Final};allspikes_2.Position{1,Unit_Final}(1,:)];
            allspikes_2.Spike{1,Unit_Final}=[allspikes_2.Spike{1,Unit_Final};allspikes_2.Spike{1,n}(ro,:)];
            %                                             allspikes_2.userdata{1,Unit_Final}=[allspikes_2.userdata{1,Unit_Final};allspikes_2.userdata{1,Unit_Final}(end,:)+1];
            allspikes_2.tsne{1,Unit_Final}=[allspikes_2.tsne{1,Unit_Final};allspikes_2.tsne{1,n}(ro,:)];
            if ~app.LoadSpikes
                allspikes_2.Time_Stamp{1,Unit_Final}=[allspikes_2.Time_Stamp{1,Unit_Final};allspikes_2.Time_Stamp{1,n}(ro,:)];
                allspikes_2.Time_Stamp{1,n}(ro,:)=[];
            end
            allspikes_2.Index{1,n}(ro,:)=[];
            %                                             allspikes_2.Position{1,n}(ro,:)=[];
            allspikes_2.Spike{1,n}(ro,:)=[];
            %                                             allspikes_2.userdata{1,n}(ro,:)=[];
            allspikes_2.tsne{1,n}(ro,:)=[];
            break
        end
    end

    k=size(allspikes_2.Spike,2)-1;

    
%                 cla(sh1)
    
     drawnow nocallbacks
    Color=hsv(k+1);
    for i=[n ,Unit_Final]
        
        cla(sh2(i),'reset')
        if   ~app.LoadSpikes
            cla(sh3(i),'reset')
        end
        
        hold(sh2(i),'on')
        
        Xi= allspikes_2.Spike{1,i};
        for s=1:size(Xi,1)
            plot(sh2(i),Xi(s,:),'Color',Color(i,:),'ButtonDownFcn', @change_Spikes, 'userdata', s);
            
        end
        
        hold(sh2(i),'off')
        if size(sh2(i).Children)
            [sh2(i).Children(1:end).DisplayName]=deal('');
            if i==1
                sh2(i).Children(end).DisplayName=('Noise (Unit #0)');
                
            else
                sh2(i).Children(end).DisplayName=(['UNIT #', num2str(i-1)]);
                
            end
            LEGEND=legend(sh2(i).Children(end));
            LEGEND.FontSize=8;
            
        end
       
        
        if ~app.LoadSpikes
            TTi=sort(allspikes_2.Time_Stamp{1,i});
            Hist_time=diff(TTi)/app.SamplingrateEditField.Value;
            size_bin=app.HistogramBinsizeEditField.Value;
            hist(sh3(i),Hist_time,size_bin)
            
            HIST_Refractory=Hist_time(Hist_time<(app.MinimumrefractoryperiodmsEditField.Value/1000));
            percent_refractory=100*size(HIST_Refractory,1)/size(TTi,1)/10000;
            
%                         pause(0.001);
            
            title(sh3(i),['About ',num2str(percent_refractory),' % of ' ,num2str(size(TTi,1)) ,' spikes are < ',num2str(app.MinimumrefractoryperiodmsEditField.Value) ,'ms'] ,'FontSize',8)
        end
        drawnow;
        
    end
    cla(sh1.Children)

    for i=0:k
        
        
        XXi=allspikes_2.tsne{1,i+1}(:,:);
        
        Style = 'o';
        MarkerSize = 6;
        
        if ~isempty(XXi)
            plot3(sh1.Children,XXi(:,1),XXi(:,2),XXi(:,3),Style,'MarkerSize',MarkerSize,'Color',Color(i+1,:));
            hold (sh1.Children,'on')
            grid(sh1.Children, 'on');
            drawnow;
            %                         pause(0.001);
        end
        
        
        
        
    end
     drawnow
     hold (sh1.Children,'off')
end
