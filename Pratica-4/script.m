clc; clear; close all;

pkg load control;

GENERATE_GRAPHS = true;

function exportgraph(filename, generate)

   if !generate
        return;
   end

    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperSize', [12.8, 7.2]);
    set(gcf, 'PaperPosition', [0, 0, 12.8, 7.2]);

    print(gcf, fullfile(pwd, filename), '-dpng', '-r400');
end

% Questão 1

K = [10, 60, 100];

t = linspace(0, 40, 200);

for i = 1:length(K)
    sys_open  = tf(K(i), conv(conv([1, 1], [1, 2]), [1, 3]));
    sys_close = tf(K(i), conv(conv([1, 1], [1, 2]), [1, 3]) + K(i));

    figure('NumberTitle', 'off', 'Name', sprintf('Questão 2a - Malha Aberta - K = %d', K(i)), 'Position', [171, 117, 1024, 576], 'Visible', 'on');

    [y, t0] = step(sys_open, t);
    hold on;
    plot(t, y, '-', 'LineWidth', 1.75, 'Color', 'b');
    plot(t, ones(size(t)), '--', 'LineWidth', 1.75, 'Color', 'r');
    plot(t, ones(size(t)) .* K(i)/6, '-.', 'LineWidth', 1.75, 'Color', 'k');
    hold off;
    grid on;

    legend('Resposta do sistema', 'Entrada u(t)', 'Erro Estacionário');

    exportgraph(sprintf('graph-2-a-%d-open', K(i)), GENERATE_GRAPHS);

    figure('NumberTitle', 'off', 'Name',  sprintf('Questão 2a - Malha Fechada - K = %d', K(i)), 'Position', [171, 117, 1024, 576], 'Visible', 'on');

    [y, t0] = step(sys_close, t);
    hold on;
    plot(t, y, '-', 'LineWidth', 1.75, 'Color', 'b');
    plot(t, ones(size(t)), '--', 'LineWidth', 1.75, 'Color', 'r');
    plot(t, ones(size(t)) .* K(i)/(6 + K(i)), '-.', 'LineWidth', 1.75, 'Color', 'k');
    hold off;
    grid on;

    legend('Resposta do sistema', 'Entrada u(t)', 'Erro Estacionário');

    exportgraph(sprintf('graph-2-a-%d-close', K(i)), GENERATE_GRAPHS);
end

% Questão 2

function [R, num_stable] = routh(P)

  n = length(P);

  if(n < 2)
     erro('P deve ter minimo de 2 coeficientes');
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
        if(all(R(i - 1, :))) == 0
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

  fprintf('\n=================================== TABELA DE ROUTH ===================================\n');
  disp(R)
  fprintf('\n=======================================================================================\n');

  if(sign_changes == 0)
    fprintf('O sistema e estavel\n');
  else
    fprintf('O sistema e instavel, houve %d mudancas de sinais\n', sign_changes);
  end
end

K = [10, 60, 100];

for i = 1:length(K)
  den = conv(conv([1, 1], [1, 2]), [1, 3]) + K(i)
  routh(den);
end

% Questão 3

den_base = conv(conv([1, 1], [1, 2]), [1, 3]);
sys_open_base = tf(1, den_base);

figure('NumberTitle', 'off', 'Name', 'Questão 2c - Lugar das Raízes (Malha Aberta)', 'Position', [171, 117, 1024, 576], 'Visible', 'on');
rlocus(sys_open_base);
title('Lugar das Raízes - Sistema em Malha Aberta');
grid on;
exportgraph('graph-2-c-open', GENERATE_GRAPHS);

% Questão 4

den_original = conv(conv([1, 1], [1, 2]), [1, 3]);
sys_G = tf(1, den_original);

sys_novo = sys_G * tf([1, 4], 1);

[num_n, den_n] = tfdata(sys_novo, 'v');

[A, B, C, D] = tf2ss(num_n, den_n);

fprintf('\n================== ESPAÇO DE ESTADOS (Questão 2d) ==================\n');
disp('Matriz A:'); disp(A);
disp('Matriz B:'); disp(B);
disp('Matriz C:'); disp(C);
disp('Matriz D:'); disp(D);
fprintf('====================================================================\n');

sys_ss = ss(A, B, C, D);

figure('NumberTitle', 'off', 'Name', 'Questão 2d - Resposta ao Degrau (Espaço de Estados)', 'Position', [171, 117, 1024, 576], 'Visible', 'on');
step(sys_ss);
grid on;
exportgraph('graph-2-d-step-ss', GENERATE_GRAPHS);

figure('NumberTitle', 'off', 'Name', 'Questão 2d - Lugar das Raízes (Espaço de Estados)', 'Position', [171, 117, 1024, 576], 'Visible', 'on');
rlocus(sys_ss);
grid on;
exportgraph('graph-2-d-rlocus-ss', GENERATE_GRAPHS);

% Questão 5

figure('NumberTitle', 'off', 'Name', 'Questão 2e - Lugar das Raízes Base', 'Position', [171, 117, 1024, 576], 'Visible', 'on');
rlocus(sys_G);
title('Lugar das Raízes - Sistema Base (K=1)');
grid on;
exportgraph('graph-2-e-base', GENERATE_GRAPHS);

zero_positions = [-0.5, -2, -5];

for idx = 1:length(zero_positions)
    z_val = zero_positions(idx);
    sys_zero = sys_G * tf([1, -z_val], 1);

    figure('NumberTitle', 'off', 'Name', sprintf('Questão 2e - LGR com Zero em z = %.1f', z_val), 'Position', [171, 117, 1024, 576], 'Visible', 'on');
    rlocus(sys_zero);
    title(sprintf('Lugar das Raízes com Zero em z = %.1f', z_val));
    grid on;
    exportgraph(sprintf('graph-2-e-zero-%.1f', abs(z_val)), GENERATE_GRAPHS);
end

% Se estiver rodando no MATLAB, remova o comentario:
% sisotool(sys_G);
