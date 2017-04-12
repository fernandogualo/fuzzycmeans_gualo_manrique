%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Algoritmo Fuzzy c medias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear,close all, clc
load('DatosCluster.csv') 
[fil, col] = size(DatosCluster);

mayorista = int16.empty(0,6);
minorista = int16.empty(0,6);

for i=1:fil
    switch DatosCluster(i,1)
        case 1
            mayorista = [mayorista; DatosCluster(i,3:8)];
        case 2
            minorista = [minorista; DatosCluster(i,3:8)];
    end
end

for i=1:6
    compras_mayorista(i) = sum(mayorista(:,i));
    compras_minorista(i) = sum(minorista(:,i));
end

total_may=sum(compras_mayorista);
total_min=sum(compras_minorista);

%%%%%%%%%%%%%% Normalización %%%%%%%%%%%%%%
mayorista_norm=double.empty(0,6);
minorista_norm=double.empty(0,6);

[mayorista_row, mayorista_col] = size(mayorista);
[minorista_fil, minorista_col] = size(minorista);

for i=1:mayorista_col
   maximo=max(mayorista(:,i)); 
   for j=1:mayorista_row
       mayorista_norm(j,i)=mayorista(j,i)/maximo;
   end
end

for i=1:minorista_col
    maximo=max(minorista(:,i));
    for j=1:minorista_fil
       minorista_norm(j,i)=minorista(j,i)/maximo;
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

for i=1:2
    Kmax=10;
    switch i
        case 1
            X=mayorista_norm;    
        case 2
            X=minorista_norm;
    end
    
    %% Uso de la función BIC para el cálculo del número de clusters    

    for K=2:Kmax
        [cidx] = kmeans(X, K,'Replicates',30);
        [Bic_K,xi]=BIC(K,cidx,X);
        BICK(K)=Bic_K;
    end
    K_ind(i)=find(BICK==min(BICK)); 
end
    
[center_mayorista,U_mayorista,obj_fcn_mayorista] = fcm(mayorista_norm, K_ind(1),opciones);
[center_minorista,U_minorista,obj_fcn_minorista] = fcm(minorista_norm, K_ind(2),opciones);

%%%%%%  Asignación de individuo a grupo, maximizando el nivel de
%       pertenencia al grupo
for i=1:K_ind(1)
    maxU=max(U_mayorista); % calculo del máximo nivel de pertenencia de los
             % individuos   
    individuos=find(U_mayorista(i,:)==maxU); % calcula los individuos del
                              % grupo i que alcanzan el máximo                   
    cidx_mayorista(individuos)=i; % asigna estos individuos al grupo i
    grado_pertenecia_may(individuos)=maxU(individuos);
end

%%%%%%  Asignación de individuo a grupo, maximizando el nivel de
%       pertenencia al grupo
for i=1:K_ind(2)
    maxU=max(U_minorista); % calculo del máximo nivel de pertenencia de los
             % individuos   
    individuos=find(U_minorista(i,:)==maxU); % calcula los individuos del
                              % grupo i que alcanzan el máximo    
    cidx_minorista(individuos)=i;           
    grado_pertenecia_minorista(individuos)=maxU(individuos);
end

lt1grupos=[length(find(cidx_mayorista==1)),length(find(cidx_mayorista==2)),length(find(cidx_mayorista==3)),length(find(cidx_mayorista==4)),length(find(cidx_mayorista==5)),length(find(cidx_mayorista==6))];
lt2grupos=[length(find(cidx_minorista==1)),length(find(cidx_minorista==2)),length(find(cidx_minorista==3)),length(find(cidx_minorista==4))];

array_mayoristas=[mean(mayorista(find(cidx_mayorista==1),:));mean(mayorista(find(cidx_mayorista==2),:));mean(mayorista(find(cidx_mayorista==3),:));mean(mayorista(find(cidx_mayorista==4),:));mean(mayorista(find(cidx_mayorista==5),:));mean(mayorista(find(cidx_mayorista==6),:))]
array_minoristas=[mean(minorista(find(cidx_minorista==1),:));mean(minorista(find(cidx_minorista==2),:));mean(minorista(find(cidx_minorista==3),:));mean(minorista(find(cidx_minorista==4),:))]

%% Media de gasto por producto (en minoristas) %%%%%%%%%%%%
figure(1)
bar([1,2,3,4,5,6],array_mayoristas','grouped')
legend('Grupo 1','Grupo 2','Grupo 3','Grupo 4','Grupo 5','Grupo 6');

%% Gasto anual total de los clientes por tipos de productos %%%%%%%%
figure(2)
bar(lt1grupos);

%% Media de gasto por producto %%%%%%%%%%%%
figure(3)
bar([1,2,3,4,5,6],array_minoristas','grouped')

legend('Grupo 1','Grupo 2','Grupo 3','Grupo 4','Grupo 5','Grupo 6');

%% Numero de clientes por grupo de pertenencia %%%%%%%%%%%%%
figure(4)
bar(lt2grupos);

[coeff_mayorista,score_mayorista,latent_mayorista] = pca(mayorista_norm);
[coeff_minorista,score_minorista,latent_minorista] = pca(minorista_norm);

%% Graficacion Distribuidor mayoristas %%%%%%%%%%
figure(5)
subplot(1,2,1)
plot(score_mayorista(cidx_mayorista==1,1),score_mayorista(cidx_mayorista==1,2),'bo','MarkerSize',6,... 
                  'MarkerEdgeColor','r', ...
                  'MarkerFaceColor','r');
hold on
plot(score_mayorista(cidx_mayorista==2,1),score_mayorista(cidx_mayorista==2,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(score_mayorista(cidx_mayorista==3,1),score_mayorista(cidx_mayorista==3,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(score_mayorista(cidx_mayorista==4,1),score_mayorista(cidx_mayorista==4,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');

xlabel('x_1','fontsize',18),ylabel('x_2','fontsize',18)
legend('Grupo 1','Grupo 2', 'Grupo 3', 'Grupo 4'),axis('square'), box on
title('Compras de Mayoristas','fontsize',18)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Centroides Distribuidor mayoristas %%%%%%%%%%%%%%%%%%%%%%%%%

plot(center_mayorista(1,1),center_mayorista(1,2),'xb',...
 'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
plot(center_mayorista(2,1),center_mayorista(2,2),'xr',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
hold off

%% Grafica Minorista 2 %%%%%%%%%%
figure(6)
subplot(1,2,2)
plot(score_minorista(cidx_minorista==1,1),score_minorista(cidx_minorista==1,2),'bo',...
'MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor','r');
hold on
plot(score_minorista(cidx_minorista==2,1),score_minorista(cidx_minorista==2,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(score_minorista(cidx_minorista==3,1),score_minorista(cidx_minorista==3,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(score_minorista(cidx_minorista==4,1),score_minorista(cidx_minorista==4,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');

xlabel('x_1','fontsize',18),ylabel('x_2','fontsize',18)
legend('Grupo 1','Grupo 2', 'Grupo 3', 'Grupo 4'),axis('square'), box on
title('Compras de Minoristas','fontsize',18)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Centroides Minorista %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot(center_minorista(1,1),center_minorista(1,2),'xb',...
 'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
plot(center_minorista(2,1),center_minorista(2,2),'xr',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
hold off