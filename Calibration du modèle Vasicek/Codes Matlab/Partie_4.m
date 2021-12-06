%%TP3 - Vasicek Model
%%Part 4 - Calibration to historical dates

function[]=Partie_4()
%% Valeurs initiales

eta = 0.6;
sigma = 0.08 ; 
gamma = 4;
T = 5;

N = 1000;
t = linspace(0,T,N); 

r0 = 0;
r(1) = r0;
r_estime(1) = r0;
r = linspace(0,T,N);
r_estime = linspace(0,T,N);


%% Calculer la variance D�, gamma, eta, sigma

%Fonction pour le calcul de la variance D�
function[D] = Calcul_Variance_D2(r,a,b)
    D = 0;
    D1 = 0;
    D2 = 0;
    N = length(r)-1;
    for i = 1:N
        D1 = D1+(r(i+1)-(a*r(i)+b))^2;
        D2 = D2+(r(i+1)-(a*r(i)+b));
    end
    D1 = D1/N;
    D2 = D2/N;
    D = D1-D2^2;
    D = sqrt(D);
end


%Fonction pour le calcul de gamma
function[gamma] = Calcul_Gamma(a,dt)
    gamma = - log(a)/dt;
end

%Fonction pour le calcul de eta
function[eta] = Calcul_Eta(gamma,a,b)
    eta = gamma * b/(1-a);
end

%Fonction pour le calcul de sigma
function[sigma] = Calcul_Sigma(D,a,dt)
    sigma = D * sqrt( (- 2 * log(a))/(dt * (1-a^2)));
end


%% Simulation des dates de march� avec les formules th�oriques

%----------------------Construction du vecteur r--------------------------
function[r,dt] = Simulation_r(t,gamma,eta,sigma)
    
    r(1) = r0;
    r = linspace(0,T,N);

    for i = 1:N-1
        dt= t(i+1) - t(i);
        u = randn;
        r(i+1) = r(i)*exp(-gamma*dt)+(eta/gamma)*(1-exp(-gamma*dt))+sigma*sqrt((1-exp(-2*gamma*dt))/(2*gamma))*u;
    end
    
end

%Appel de la fonction
[r,dt] = Simulation_r(t,gamma,eta,sigma);



%---Fonction permettant de r�aliser le trac� de r en fonction du temps----
function[r] = Graphique_r_Temps(t,r)
    
    %Trac� du graphique de r en fonction du temps
    figure;
    plot(t,r)
    title("Evolution de r en fonction du temps")
    xlabel("Temps")
    ylabel("r")
    
end

%Appel de la fonction
Graphique_r_Temps(t,r)



%-----------Fonction permettant de r�aliser le trac� de r(i)-------------
%----------------------------en fonction de r(i+1) ----------------------
function[r] = Graphique_r(r)
    
    %Trac� du graphique r(i) en fonction de r(i+1)
    figure;
    hold on;
    
    for j = 1:N-1
        plot(r(j),r(j+1),"g+");
    end
    
    xlabel("r(i)")
    ylabel("r(i+1)")
    title("Graphique de r(i) en fonction de r(i+1)")
    
end

%Appel de la fonction
Graphique_r(r)



%% Calibration et estimation des param�tres

function[r] = Calibration_Historical_Dates(r,dt)
        
    %Graphique des points r(i) r(i+1)
    Graphique_r(r);
    
    
    %Realisation de la r�gression lin�aire
    x = ones(length(r)-1,2);
    for i = 1: (length(r)-1)
        x(i,1) = r(i);
    end
    
    
    %D�termination des param�tres et trac� de la droite estim�e
    y = r(2:length(r))';
    coefficient_regression = x\y;
    a_estime = coefficient_regression(1);
    b_estime = coefficient_regression(2);
    droite_estime = x(:,1) * a_estime + b_estime;
    plot(x(:,1),droite_estime,'blue');
    
    
    %D�termination des param�tres et trac� de la droite th�orique
    a_theorique = exp(-gamma*dt);
    b_theorique = (eta/gamma)*(1-exp(-gamma*dt));
    droite_theorique = a_theorique*r+b_theorique;
    plot(r,droite_theorique,'magenta');
    
    
    %Ajout des labels
    xlabel('r')
    ylabel('y=ax+b')
    title('R�gression lin�aire sur les points de march� selon les coefficients utilis�s')
    
    
    %Calcul des param�tres estim�s sigma, eta et gamma � partir des
    %formules th�oriques mais en prenant les param�tres estim�s et trouv�s
    %pr�cedemment lors de la r�gression lin�aire pour la droite estim�e
    D = Calcul_Variance_D2(r,a_estime,b_estime); 
    gamma_estime = Calcul_Gamma(a_estime,dt);
    eta_estime = Calcul_Eta(gamma_estime, a_estime, b_estime); 
    sigma_estime = Calcul_Sigma(D,a_estime,dt);
    
    
    %Comparaison des param�tres th�oriques et estim�s
    disp('-----------------------------------------')
    disp(['La valeur de a th�orique pour la r�gression lin�aire y=ax+b = ', num2str(a_theorique)])
    disp(['La valeur de a estim�e de la r�gression lin�aire y=ax+b = ', num2str(a_estime)])
    disp('-----------------------------------------')
    disp(['La valeur de b th�orique pour la r�gression lin�aire y=ax+b = ', num2str(b_theorique)])
    disp(['La valeur de b estim�e de la r�gression lin�aire y=ax+b = ', num2str(b_estime)])
    disp('-----------------------------------------')
    disp(['La valeur de la variance D^2 est : ',num2str(D^2)])
    disp('-----------------------------------------')
    disp(['Gamma th�orique = ',num2str(gamma)])
    disp(['Gamma estim� = ',num2str(gamma_estime)])
    disp('-----------------------------------------')
    disp(['Eta th�orique = ',num2str(eta)])
    disp(['Eta estim� = ',num2str(eta_estime)])
    disp('-----------------------------------------')
    disp(['Sigma th�orique = ',num2str(sigma)])
    disp(['Sigma estim� = ',num2str(sigma_estime)])
    disp('-----------------------------------------')
    
end

Calibration_Historical_Dates(r,dt);


end