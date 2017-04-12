%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Algoritmo Fuzzy c medias
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear,close all, clc
load('DatosCluster.csv') 
[fil, col] = size(DatosCluster);

titulos={'Frescos' 'Lacteos' 'Ultramarinos' 'Congelados' 'Papeleria' 'Delicatessen'};

for tr=1:2
%%%%%%%%%%%%%% Normalización %%%%%%%%%%%%%%
for i=1:col
   maximo=max(DatosCluster(:,i)); 
   for j=1:fil
       data_norm(j,i)=DatosCluster(j,i)/maximo;
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data = {[data_norm(:,tr) data_norm(:,3)],[data_norm(:,tr) data_norm(:,4)],[data_norm(:,tr) data_norm(:,5)],[data_norm(:,tr) data_norm(:,6)],[data_norm(:,tr) data_norm(:,7)],[data_norm(:,tr) data_norm(:,8)]};

%%%%%%%%%%%%%% Fuzzy c-medias %%%%%%%%%%%%%
K=4;                       % número de cluster
m=2;                       % parámetro de fcm, 2 es el defecto
MaxIteraciones=100;        % número de iteraciones
Tolerancia= 1e-5;          % tolerancia en el criterio de para
Visualizacion=0;           % 0/1
opciones=[m,MaxIteraciones,Visualizacion];

center=cell(1,6);
U=cell(1,6);
obj_fcn=cell(1,6);
K_ind=int16.empty(0);

for d=1:6
    
    %% calculo del numero de cluster K
    %% Uso de la función BIC para el cálculo del número de clusters    
    Kmax=10;
    X=data{d};
    
    for K=2:Kmax
        [cidx] = kmeans(X, K,'Replicates',30);
        [Bic_K,xi]=BIC(K,cidx,X);
        BICK(K)=Bic_K;
    end
    K_ind(d)=find(BICK==min(BICK));
    [center{d},U{d},obj_fcn{d}] = fcm(data{d},K_ind(d),opciones);

%%%%%%  Asignación de individuo a grupo, maximizando el nivel de
%       pertenencia al grupo    
    for i=1:K_ind(d)
        maxU=max(U{d});% calcula los individuos del
                              % grupo i que alcanzan el máximo
        U_m=U{d};
        individuos=find(U_m(i,:)==maxU);   % calcula los individuos del
                              % grupo i que alcanzan el máximo                                    
        cidx(individuos,d)=i;% asigna estos individuos al grupo i
        grado_pertenecia(individuos)=maxU(individuos);
    end

%%%%%%%%%%%  Gastos por tipo de cliente %%%%%%%%%%
figure(tr)
subplot(2,3,d)
datos=data{d};
plot(datos(cidx(:,d)==1,1),datos(cidx(:,d)==1,2),'bo','MarkerSize',6,... 
 'MarkerEdgeColor','r','MarkerFaceColor','r');
hold on
plot(datos(cidx(:,d)==2,1),datos(cidx(:,d)==2,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(datos(cidx(:,d)==3,1),datos(cidx(:,d)==3,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(datos(cidx(:,d)==4,1),datos(cidx(:,d)==4,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');
plot(datos(cidx(:,d)==5,1),datos(cidx(:,d)==5,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','m');
plot(datos(cidx(:,d)==6,1),datos(cidx(:,d)==6,2),'bo',...
 'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Centroides %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(center(1,1),center(1,2),'xb',...
'MarkerSize',6,'MarkerEdgeColor','r', 'MarkerFaceColor','r');
plot(center(2,1),center(2,2),'xr',...
'MarkerSize',6,'MarkerEdgeColor','b', 'MarkerFaceColor','b');
plot(center(3,1),center(3,2),'xb',...
'MarkerSize',6,'MarkerEdgeColor','g', 'MarkerFaceColor','g');
plot(center(4,1),center(4,2),'xr',...
'MarkerSize',6,'MarkerEdgeColor','c', 'MarkerFaceColor','c');
plot(center(5,1),center(5,2),'xb',...
'MarkerSize',6,'MarkerEdgeColor','m', 'MarkerFaceColor','m');
plot(center(6,1),center(6,2),'xr',...
'MarkerSize',6,'MarkerEdgeColor','y', 'MarkerFaceColor','y');

xlabel('Tipo Cliente','fontsize',18),ylabel('Gasto','fontsize',18)
legend('Grupo 1','Grupo 2', 'Grupo 3', 'Grupo 4', 'Grupo 5', 'Grupo 6'),axis('square'), box on
title(titulos{d},'fontsize',18)

hold off
end
end