%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Algoritmo Fuzzy c medias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear,close all, clc
load('DatosCluster.csv') 
[fil, col] = size(DatosCluster);

%%%%%%%%%%%%%% Normalización %%%%%%%%%%%%%%
for i=1:col
   maximo=max(DatosCluster(:,i)); 
   for j=1:fil
       data_norm(j,i)=DatosCluster(j,i)/maximo;
   end
end

%%%%%%%%%%%%%% Fuzzy c-medias %%%%%%%%%%%%%
K=4;                       % número de cluster
m=2;                       % parámetro de fcm, 2 es el defecto
MaxIteraciones=100;        % número de iteraciones
Tolerancia= 1e-5;          % tolerancia en el criterio de para
Visualizacion=0;           % 0/1
opciones=[m,MaxIteraciones,Visualizacion];


%% Uso de la función BIC para el cálculo del número de clusters    
    Kmax=10;
    X=data_norm;
    for K=2:Kmax
        [cidx] = kmeans(X, K,'Replicates',30);
        [Bic_K,xi]=BIC(K,cidx,X);
        BICK(K)=Bic_K;
    end

    K_ind=find(BICK==min(BICK));
    [center,U,obj_fcn] = fcm(data_norm,K_ind,opciones);
    
%%%%%%  Asignación de individuo a grupo, maximizando el nivel de
%       pertenencia al grupo
    for i=1:K_ind
        maxU=max(U);% calcula los individuos del
                              % grupo i que alcanzan el máximo
        individuos=find(U(i,:)==maxU); % calcula los individuos del
                              % grupo i que alcanzan el máximo                   
        cidx(individuos)=i; % asigna estos individuos al grupo i
        grado_pertenecia(individuos)=maxU(individuos);
    end

grupos_clientes=[length(find(cidx==1)),length(find(cidx==2)),length(find(cidx==3)),length(find(cidx==4)),length(find(cidx==5)),length(find(cidx==6))];

%%%%%%%% Media de gasto por propiedad de los clientes %%%%%%%%%%

figure(1)
bar([1,2,3,4,5,6,7,8],[mean(DatosCluster(find(cidx==1),:));mean(DatosCluster(find(cidx==2),:));mean(DatosCluster(find(cidx==3),:));mean(DatosCluster(find(cidx==4),:));mean(DatosCluster(find(cidx==5),:));mean(DatosCluster(find(cidx==6),:))]','grouped');

%%%% Numero de clientes por grupo %%%%
figure(2)
bar(grupos_clientes);

[coeff,score,latent] = pca(data_norm);

%%%%%%%%%%%  Distribución clientes por grupos con centroides  %%%%%%%%%%
figure(3)
plot(score(cidx==1,1),score(cidx==1,2),'bo','MarkerSize',6,... 
 'MarkerEdgeColor','r','MarkerFaceColor','r');
hold on
plot(score(cidx==2,1),score(cidx==2,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(score(cidx==3,1),score(cidx==3,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(score(cidx==4,1),score(cidx==4,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');
plot(score(cidx==5,1),score(cidx==5,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','m');
plot(score(cidx==6,1),score(cidx==6,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','y');

[coeff_clientes,score_clientes,latent_clientes] = pca(center);

plot(score_clientes(1,1),score_clientes(1,2),'xb',...
 'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
plot(score_clientes(2,1),score_clientes(2,2),'xr',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(score_clientes(3,1),score_clientes(3,2),'xb',...
 'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(score_clientes(4,1),score_clientes(4,2),'xr',...
 'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');
plot(score_clientes(5,1),score_clientes(5,2),'xb',...
 'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','m');
plot(score_clientes(6,1),score_clientes(6,2),'xr',...
 'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','y');

xlabel('x_1','fontsize',18),ylabel('x_2','fontsize',18)
legend('Grupo 1', 'Grupo 2', 'Grupo 3', 'Grupo 4', 'Grupo 5', 'Grupo 6'),axis('square'), box on
title('DatosCluster','fontsize',18)