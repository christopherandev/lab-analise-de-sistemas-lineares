% =========================================================================
% TRABALHO DE ANÁLISE DE SISTEMAS LINEARES - SIMULAÇÃO COMPLETA
% Sistema: Controle de Altitude de um Quadricóptero
% =========================================================================
clear; close all; clc;

% Carregar pacotes necessários
pkg load control;
pkg load signal;

% =========================================================================
% FUNÇÃO AUXILIAR: TABELA DE ROUTH
% =========================================================================
function [R, num_stable] = routh_func(P)
  n = length(P);
  if(n < 2)
     error('P deve ter minimo de 2 coeficientes');
  end

  deg  = n - 1;
  cols = ceil(n / 2);
  R = zeros(n, cols);

  R(1, :) = P(1:2:end);
  row2  = P(2:2:end);
  R(2, 1:length(row2)) = row2;

  esp_value = eps('double');

  for i = 3:n
    if R(i - 1, 1) == 0
        if(all(R(i - 1, :)) == 0)
          aux_deg = deg - (i - 3);
          exp_vec = aux_deg:-2:0;
          aux_p   = R(i-2, 1:length(exp_vec));
          R(i - 1, 1:length(exp_vec)) = aux_p .* exp_vec;
         else
          R(i - 1, 1) = esp_value;
        end
    end

    for j = 1:(cols - 1)
        pivot = R(i - 1, 1);
        num = R(i - 1, 1) * R(i - 2, j + 1) - R(i - 2, 1) * R(i - 1, j + 1);
        R(i, j) = num / pivot;
    end
  end

  col1 = R(:, 1);
  col1(abs(col1) < 1e-12) = esp_value;
  sign_changes = sum(diff(sign(col1)) ~= 0);
  num_stable = sign_changes;

  fprintf('\n------------------ TABELA DE ROUTH ------------------\n');
  disp(R)
  fprintf('-------------------------------------------------------\n');

  if(sign_changes == 0)
    fprintf('Resultado Routh: O sistema em malha fechada e ESTAVEL.\n\n');
  else
    fprintf('Resultado Routh: O sistema em malha fechada e INSTAVEL (%d mudancas de sinal).\n\n', sign_changes);
  end
end

GENERATE_GRAPHS = true;

function exportgraph(filename, generate)

   if !generate
        return;
    endif

    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperSize', [12.8, 7.2]);
    set(gcf, 'PaperPosition', [0, 0, 12.8, 7.2]);

    print(gcf, fullfile(pwd, filename), '-dpng', '-r300');
end


disp('===================================================================');
disp(' 1. MODELAGEM DA PLANTA EM MALHA ABERTA');
disp('===================================================================');

%% 1. PARÂMETROS FÍSICOS E FUNÇÃO DE TRANSFERÊNCIA
m = 1.50;          % massa do drone [kg]
g = 9.81;          % gravidade [m/s^2]
b = 1.00;          % arrasto vertical equivalente [N.s/m]

% Função de Transferência da Planta: G(s) = 1 / (m*s^2 + b*s)
num_G = [1];
den_G = [m, b, 0];
G_MA = tf(num_G, den_G);

disp('Funcao de Transferencia da Planta G(s):');
G_MA
disp('Polos da Planta em Malha Aberta:');
disp(pole(G_MA));

% Resposta ao degrau em malha aberta
figure(1);
step(G_MA);
title('Resposta ao Degrau - Malha Aberta');
grid on;
exportgraph('step-malha-aberta', GENERATE_GRAPHS);

disp('===================================================================');
disp(' 2. CONTROLADOR PROPORCIONAL E LUGAR DAS RAÍZES');
disp('===================================================================');

Kp = 2.0; % Ganho proporcional inicial escolhido
C_P = tf([Kp], [1]);

% Malha Fechada com controlador P
G_MF_P = feedback(C_P * G_MA, 1);

disp('Funcao de Transferencia em Malha Fechada (com Kp):');
G_MF_P

figure(2);
rlocus(G_MA);
title('Lugar das Raizes da Planta (Malha Aberta)');
grid on;
exportgraph('rlocus-degrau-malha-aberta', GENERATE_GRAPHS);


disp('===================================================================');
disp(' 3. ANÁLISE DE RESPOSTA TRANSITÓRIA E DESEMPENHO');
disp('===================================================================');

figure(3);
step(G_MF_P);
title(['Resposta ao Degrau em Malha Fechada (Kp = ', num2str(Kp), ')']);
grid on;
exportgraph('step-malha-fechada', GENERATE_GRAPHS);

disp('Especificacoes de Desempenho (stepinfo):');
disp(stepinfo(G_MF_P));

disp('===================================================================');
disp(' 4. CRITÉRIO DE ROUTH-HURWITZ');
disp('===================================================================');
% Polinômio característico da malha fechada: m*s^2 + b*s + Kp = 0
% Extraindo os coeficientes para a tabela de Routh
poly_carac = [m, b, Kp];
[R_table, num_stable_poles] = routh_func(poly_carac);

disp('===================================================================');
disp(' 5. RESPOSTA EM FREQUÊNCIA E ESTABILIDADE RELATIVA');
disp('===================================================================');

figure(4);
bode(C_P * G_MA);
title('Diagrama de Bode');
grid on;
exportgraph('bode', GENERATE_GRAPHS);

figure(5);
nyquist(C_P * G_MA);
title('Diagrama de Nyquist');
grid on;
exportgraph('nyquist', GENERATE_GRAPHS);

figure(6);
nichols(C_P * G_MA);
title('Diagrama de Nichols');
grid on;
exportgraph('nichols', GENERATE_GRAPHS);

[Gm, Pm, Wcg, Wcp] = margin(C_P * G_MA);
fprintf('Margem de Ganho (Gm): %.2f dB (ou %.4f)\n', 20*log10(Gm), Gm);
fprintf('Margem de Fase (Pm): %.2f graus\n', Pm);
fprintf('Frequencia de Cruzamento de Ganho (Wcg): %.4f rad/s\n', Wcg);
fprintf('Frequencia de Cruzamento de Fase (Wcp): %.4f rad/s\n', Wcp);

disp('===================================================================');
disp(' 6. SISTEMAS DE FASE NÃO-MÍNIMA E ATRASO DE TRANSPORTE');
disp('===================================================================');
% Simulando um atraso de transporte de 0.1s via aproximação de Padé
tau_delay = 0.1;
[num_p, den_p] = pade(tau_delay, 2);
G_delay = tf(num_p, den_p);

% Adicionando dinâmica de fase não-mínima (ex: zero no semiplano direito)
G_nao_minima = tf([-0.5, 1], [1]);
G_composto = G_MA * G_delay * G_nao_minima;

figure(7);
step(feedback(G_composto, 1));
title('Resposta ao Degrau - Sistema com Atraso e Fase Não-Mínima');
grid on;
exportgraph('step-sistema-atrasado-fase-nm', GENERATE_GRAPHS);

