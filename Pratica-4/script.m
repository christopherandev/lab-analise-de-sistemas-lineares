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

    print(gcf, fullfile(pwd, filename), '-dpng', '-r200');
end

 Questão 1

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

sys__open  = tf(1, conv(conv([1, 1], [1, 2]), [1, 3]));
sys__close = tf(1, conv(conv([1, 1], [1, 2]), [1, 3]) + 1);

figure('NumberTitle', 'off', 'Name', 'Questão 2c - Malha Aberta', 'Position', [171, 117, 1024, 576], 'Visible', 'on');
rlocus(sys__open);
exportgraph('graph-2-c-open', true);
figure('NumberTitle', 'off', 'Name', 'Questão 2c - Malha Fechada', 'Position', [171, 117, 1024, 576], 'Visible', 'on');
rlocus(sys__close);
exportgraph('graph-2-c-close', true);
