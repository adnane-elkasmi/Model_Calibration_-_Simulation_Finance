%TP5 - Calibration du mod�le de Heston


%Partie 1 - Simulation du mod�le de Heston
%Sous-Part 1 - Log Return


function[]=Partie_1_1()
    %% Valeurs initiales
    
    K=1;
    r=0.01;
    k=2;
    rho=-0.9;
    theta=0.04;
    eta=0.3;
    N=100;

    %Discr�tisation de l'intervalle [0,T]
    T=0.5;
    deltat=T/N;
    t=linspace(0,T,N+1);

    %Nombre de simulations Monte-Carlo
    Nmc=10000;

    %% Fonctions initiales � impl�menter
    
    %Calcul de l'actif S et de la volatilit� v
    function[S,v]=Calcul_ActifVola(rho)

        S(1)=1;
        v(1)=0.04;

        for i=1:N
            N1=randn;
            N2=randn;
            v(i+1)=v(i)+k*(theta-v(i))*deltat+eta*sqrt(abs(v(i)))*sqrt(deltat)*N1+(eta^2/4)*(deltat*N1^2-deltat);
            S(i+1)=S(i)*exp((r-v(i)/2)*deltat+sqrt(abs(v(i)))*(rho*sqrt(deltat)*N1+sqrt(1-rho^2)*sqrt(deltat)*N2));
        end
        
    end

    %Simulation de la densit� de la loi de Poisson pour une variable
    %al�atoire X
    function[x,Densite]=Densite_Loi_Poisson(X)
        
        a=-1; 
        b=1; 
        Nx=100;
        x=linspace(a,b,Nx);
        deltax=(b-a)/Nx;
        
        for i=1:Nx
            
            compteur=0;
            
            for n=1:Nmc
                if x(i)<=X(n) && X(n)<=x(i)+deltax
                    compteur=compteur+1;
                end
            end
            
            Proba(i)=compteur/Nmc;
            Densite(i)=Proba(i)/deltax;
            
        end
        
    end


    %Realisation de NMC simulations
    function[X]=Simulation_Nmc_ActifVola(rho)
        
        for j=1:Nmc
            [S,v]=Calcul_ActifVola(rho); 
            X(j)=log(S(N+1)/S(1));
        end 
        
    end


    %% Fonction de tracage des courbes d'�volutions et de densit�
    
    %Fonction pour l'affichage de la courbe d'�volution de la volatilit� v
    function[]=Evolution_volatilite(t,rho)
        
        figure;
        hold on;
        
        for l=1:4
            [S_simul,v_simul]=Calcul_ActifVola(rho);
            plot(t,v_simul); 
        end

        title('Courbe d evolution de la volatilit� vi de l''actif S')
        legend('Simulation 1', 'Simulation 2', 'Simulation 3', 'Simulation 4');
        xlabel('Temps t');
        ylabel('Volatilit� v');
        
    end


    %Fonction pour l'affichage de la courbe d'�volution de l'actif S
    function[]=Evolution_actif(t,rho)
        
        figure;
        hold on;
        
        for l=1:4
            [S_simul,v_simul]=Calcul_ActifVola(rho);
            plot(t,S_simul); 
        end

        title('Courbe d evolution de l actif S')
        legend('Simulation 1', 'Simulation 2', 'Simulation 3', 'Simulation 4');
        xlabel('Temps t');
        ylabel('Prix S');
        
    end


    %Fonction pour l'affichage de la fonction densit� du log return
    function[]=Log_return_function(rho1,rho2,rho3)
        
        X1 = Simulation_Nmc_ActifVola(rho1);
        X2 = Simulation_Nmc_ActifVola(rho2);
        X3 = Simulation_Nmc_ActifVola(rho3);
        
        [x,Densite1] = Densite_Loi_Poisson(X1);
        [x,Densite2] = Densite_Loi_Poisson(X2);
        [x,Densite3] = Densite_Loi_Poisson(X3);

        figure;
        plot(x,Densite1,x,Densite2,x,Densite3);
        title('Fonction de densit� du "Log return"')
        legend('rho = 0', 'rho = 0.9', 'rho = -0.9'); % A modifier en cas de changement de valeur des rhos
        xlabel('x');
        ylabel('Densit� f(x)');
        
    end


    
    %% Appel des fonctions / Tests
    
    %Courbe d'�volution de la volatilit�
    Evolution_volatilite(t,rho)
    
    %Courbe d'�volution de l'actif
    Evolution_actif(t,rho)
    
    %Simulation Nmc fois Log Return
    Log_return_function(0,0.9,-0.9)
    
    
end