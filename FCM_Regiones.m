%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Algoritmo Fuzzy c medias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear,close all, clc
load('DatosCluster.csv') 
[row, col] = size(DatosCluster);

% Lisboa 1, oporto 2, other 3
lisboa = int16.empty(0,6);
oporto = int16.empty(0,6);
other =  int16.empty(0,6);

for i=1:row
    switch DatosCluster(i,2)
        case 1
            lisboa = [lisboa; DatosCluster(i,3:8)];
        case 2
            oporto = [oporto; DatosCluster(i,3:8)];
        case 3
            other = [other; DatosCluster(i,3:8)];  
    end
end

%%%%%%%%%%%%%% Normalización %%%%%%%%%%%%%%
lisboa_norm=double.empty(0,6);
oporto_norm=double.empty(0,6);
other_norm=double.empty(0,6);

[lisboa_row, lisboa_col] = size(lisboa);
[oporto_row, oporto_col] = size(oporto);
[other_row, other_col] = size(other);

for i=1:3
    switch i
        case 1
            for j=1:lisboa_col
                maximo=max(lisboa(:,j)); 
                for k=1:lisboa_row
                    lisboa_norm(k,j)=lisboa(k,j)/maximo;
                end
            end
        case 2
            for j=1:oporto_col
                maximo=max(oporto(:,j)); 
                for k=1:oporto_row
                    oporto_norm(k,j)=oporto(k,j)/maximo;
                end
            end
        case 3
            for j=1:other_col
                maximo=max(other(:,j));
                for k=1:other_row
                    other_norm(k,j)=other(k,j)/maximo;
                end
            end
    end    
end

%%%%%%%%%%%%%% Fuzzy c-medias %%%%%%%%%%%%%
K=4;                       % número de cluster
m=2;                       % parámetro de fcm, 2 es el defecto
MaxIteraciones=100;        % número de iteraciones
Tolerancia= 1e-5;          % tolerancia en el criterio de para
Visualizacion=0;           % 0/1
opciones=[m,MaxIteraciones,Visualizacion];

%% calculo del numero de cluster K
for i=1:3
    Kmax=10;
    switch i
        case 1
          X=lisboa_norm;
        case 2
          X=oporto_norm;
        case 3
         X=other_norm; 
    end
    
%% Uso de la función BIC para el cálculo del número de clusters    
    for K=2:Kmax
        [cidx] = kmeans(X, K,'Replicates',30);
        [Bic_K,xi]=BIC(K,cidx,X);
        BICK(K)=Bic_K;
    end
    K_ind(i)=find(BICK==min(BICK));
end

[center_lisboa,U_lisboa,obj_fcn_lisboa] = fcm(lisboa_norm, K_ind(1),opciones);
[center_oporto,U_oporto,obj_fcn_oporto] = fcm(oporto_norm, K_ind(2),opciones);
[center_other,U_other,obj_fcn_other] = fcm(other_norm, K_ind(3),opciones);

%%%%%%  Asignación de individuo a grupo, maximizando el nivel de
%       pertenencia al grupo para lisboa
for i=1:K_ind(1)
    maxU=max(U_lisboa);    % calculo del máximo nivel de pertenencia de los
                        % individuos
    individuos=find(U_lisboa(i,:)==maxU);  % calcula los individuos del
                                        % grupo i que alcanzan el máximo
    cidx_lisboa(individuos)=i; % asigna estos individuos al grupo i
    grado_pertenecia_lisboa(individuos)=maxU(individuos);
end

%%%%%%  Asignación de individuo a grupo, maximizando el nivel de
%       pertenencia al grupo para oporto
for i=1:K_ind(2)
    maxU=max(U_oporto);     % calculo del máximo nivel de pertenencia de los
                        % individuos
    individuos=find(U_oporto(i,:)==maxU);   % calcula los individuos del
                                        % grupo i que alcanzan el máximo     
    cidx_oporto(individuos)=i; % asigna estos individuos al grupo i
    grado_pertenecia_oporto(individuos)=maxU(individuos);
end

%%%%%%  Asignación de individuo a grupo, maximizando el nivel de
%       pertenencia al grupo para other
for i=1:K_ind(3)
    maxU=max(U_other);     % calculo del máximo nivel de pertenencia de los
                        % individuos 
    individuos=find(U_other(i,:)==maxU);   % calcula los individuos del
                                        % grupo i que alcanzan el máximo                  
    cidx_other(individuos)=i;
    grado_pertenecia_other(individuos)=maxU(individuos);
end

[coeffl,score_lis,latentl] = pca(lisboa_norm);
[coeffp,score_op,latentp] = pca(oporto_norm);
[coefft,score_ot,latentt] = pca(other_norm);

%% Compras por zona %%%%%
%%%%  Gráfico de Lisboa %%%%%%%%%%
figure(1)
subplot(1,3,1)
plot(score_lis(cidx_lisboa==1,1),score_lis(cidx_lisboa==1,2),'bo','MarkerSize',6,... 
                  'MarkerEdgeColor','r', ...
                  'MarkerFaceColor','r');
hold on
plot(score_lis(cidx_lisboa==2,1),score_lis(cidx_lisboa==2,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(score_lis(cidx_lisboa==3,1),score_lis(cidx_lisboa==3,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(score_lis(cidx_lisboa==4,1),score_lis(cidx_lisboa==4,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');

xlabel('x_1','fontsize',18),ylabel('x_2','fontsize',18)
legend('Grupo 1','Grupo 2', 'Grupo 3', 'Grupo 4'),axis('square'), box on
title('Compras de lisboa','fontsize',18)

%%% Centroides Lisboa %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(center_lisboa(1,1),center_lisboa(1,2),'xb',...
 'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
plot(center_lisboa(2,1),center_lisboa(2,2),'xr',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
hold off

%%% Graficacion Oporto  %%%%%%%%%%
subplot(1,3,2)
plot(score_op(cidx_oporto==1,1),score_op(cidx_oporto==1,2),'bo',...
'MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor','r');
hold on
plot(score_op(cidx_oporto==2,1),score_op(cidx_oporto==2,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(score_op(cidx_oporto==3,1),score_op(cidx_oporto==3,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(score_op(cidx_oporto==4,1),score_op(cidx_oporto==4,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');

xlabel('x_1','fontsize',18),ylabel('x_2','fontsize',18)
legend('Grupo 1','Grupo 2', 'Grupo 3', 'Grupo 4'),axis('square'), box on
title('Compras de Oporto','fontsize',18)

%%% Centroides Oporto %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(center_oporto(1,1),center_oporto(1,2),'xb',...
 'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
plot(center_oporto(2,1),center_oporto(2,2),'xr',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
hold off

%%%  Graficas otros %%%%%%%%%%
subplot(1,3,3)
plot(score_ot(cidx_other==1,1),score_ot(cidx_other==1,2),'bo',...
'MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor','r');
hold on
plot(score_ot(cidx_other==2,1),score_ot(cidx_other==2,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(score_ot(cidx_other==3,1),score_ot(cidx_other==3,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(score_ot(cidx_other==4,1),score_ot(cidx_other==4,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');

xlabel('x_1','fontsize',18),ylabel('x_2','fontsize',18)
legend('Grupo 1','Grupo 2', 'Grupo 3', 'Grupo 4'),axis('square'), box on
title('Compras de Oporto','fontsize',18)

%%% Centroides otros %%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(center_other(1,1),center_other(1,2),'xb',...
 'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
plot(center_other(2,1),center_other(2,2),'xr',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
hold off


r1=[mean(lisboa(find(cidx_lisboa==1),:));mean(lisboa(find(cidx_lisboa==2),:));mean(lisboa(find(cidx_lisboa==3),:));mean(lisboa(find(cidx_lisboa==4),:))];
r2=[mean(oporto(find(cidx_oporto==1),:));mean(oporto(find(cidx_oporto==2),:));mean(oporto(find(cidx_oporto==3),:))];
r3=[mean(other(find(cidx_other==1),:));mean(other(find(cidx_other==2),:));mean(other(find(cidx_other==3),:));mean(other(find(cidx_other==4),:));mean(other(find(cidx_other==5),:));mean(other(find(cidx_other==6),:));mean(other(find(cidx_other==7),:))];

lr1groups=[length(find(cidx_lisboa==1)),length(find(cidx_lisboa==2)),length(find(cidx_lisboa==3)),length(find(cidx_lisboa==4))];
lr2groups=[length(find(cidx_oporto==1)),length(find(cidx_oporto==2)),length(find(cidx_oporto==3))];
lr3groups=[length(find(cidx_other==1)),length(find(cidx_other==2)),length(find(cidx_other==3)),length(find(cidx_other==4)),length(find(cidx_other==5)),length(find(cidx_other==6)),length(find(cidx_other==7))];

%% Clientes por grupo en Lisboa%%%
figure(2)
bar([1,2,3,4,5,6],r1','grouped')
legend('Grupo 1','Grupo 2','Grupo 3','Grupo 4');

%% Clientes por grupo en lisboa%%%
figure(3)
bar(lr1groups);

%% Clientes por grupo en Oporto%%%
figure(4)
bar([1,2,3,4,5,6],r2','grouped')
legend('Grupo 1','Grupo 2','Grupo 3');

%% Clientes por región  en Oporto%%%
figure(5)
bar(lr2groups);

%% Gasto medio por producto %%%
figure(6)
bar([1,2,3,4,5,6],r3','grouped')
legend('Grupo 1','Grupo 2','Grupo 3','Grupo 4','Grupo 5','Grupo 6', 'Grupo 7');

%% Clientes por grupo en otras regiones %%%
figure(7)
bar(lr3groups);