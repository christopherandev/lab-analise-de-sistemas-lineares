clc; close all; clear;

pkg load control;

GENERATE_GRAPHS = true;

function exportgraph(filename, generate)

   if !generate
        return;
    endif

    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperSize', [12.8, 7.2]);
    set(gcf, 'PaperPosition', [0, 0, 12.8, 7.2]);

    print(gcf, fullfile(pwd, filename), '-dpng', '-r400');
end

% Questão 2

k = 100;
u = ones(k);
R = 470e3;
C = 1e-6;
B = (R*C)/10;

y(1) = 0;
for i = 2 : k
    y(i) = (1 - B) * y(i - 1) + B * u(i - 1);
end

figure('NumberTitle', 'off', 'Name', 'Questão 2', 'Position', [171, 117, 1025, 576]);
plot(y, '*', 'MarkerSize', 10, 'Color', 'blue');
stem(y, 'filled', 'Linewidth', 1.5);
title('Simulação da Equação Diferença');
xlabel('Tempo (s)');
ylabel('Amplitude');

exportgraph('graph-2', GENERATE_GRAPHS);

% Questão 3a

function temporal_response(t, sys, sys_name, letter, can_generate)

  impulse   = @(t, k = 0) (t == k);
  ustep     = @(t) (ones(size(t)));
  ramp      = @(t) (t .* ones(size(t)));
  parabolic = @(t) (t .^2 .* ones(size(t)));

  figure('NumberTitle', 'off', 'Name', sprintf('Questão 3.%s - Respostas', letter), 'Position', [171, 117, 1025, 576]);

  subplot(2, 2, 1);
  [y, t0] = lsim(sys, impulse(t), t);
  hold on;
  plot(t0, y, 'Color', 'b', 'Linewidth', 2.15);
  xlabel('Tempo (s)');
  ylabel('Amplitude');
  plot(t, impulse(t), '--', 'Color', 'r', 'Linewidth', 2.15);
  title(sprintf('Resposta ao impulso: %s', sys_name));
  legend('Resposta do sistema', 'Entrada');
  hold off;

  subplot(2, 2, 2);
  [y, t0] = lsim(sys, ustep(t), t);
  hold on;
  plot(t0, y, 'Color', 'b', 'Linewidth', 2.15);
  xlabel('Tempo (s)');
  ylabel('Amplitude');
  plot(t, ustep(t), '--', 'Color', 'r', 'Linewidth', 2.15);
  title(sprintf('Resposta ao degrau: %s', sys_name));
  legend('Resposta do sistema', 'Entrada');

  subplot(2, 2, 3);
  [y, t0] = lsim(sys, ramp(t), t);
  hold on;
  plot(t0, y, 'Color', 'b', 'Linewidth', 2.15);
  xlabel('Tempo (s)');
  ylabel('Amplitude');
  plot(t, ramp(t), '--', 'Color', 'r', 'Linewidth', 2.15);
  title(sprintf('Resposta à rampa: %s', sys_name));
  legend('Resposta do sistema', 'Entrada');

  subplot(2, 2, 4);
  [y, t0] = lsim(sys, parabolic(t), t);
  hold on;
  plot(t0, y, 'Color', 'b', 'Linewidth', 2.15);
  xlabel('Tempo (s)');
  ylabel('Amplitude');
  plot(t, parabolic(t), '--', 'Color', 'r', 'Linewidth', 2.15);
  title(sprintf('Resposta à parábola: %s', sys_name));
  legend('Resposta do sistema', 'Entrada');

  exportgraph(sprintf('graph-3-%s-responses', letter), can_generate);

  figure('NumberTitle', 'off', 'Name', sprintf('Questão 3.%s - pzmap', letter), 'Position', [171, 117, 1025, 576]);
  [pole, zero] = pzmap(sys);

  hold on;
  h_pole = plot(real(pole), imag(pole), 'x', 'MarkerSize', 15, 'LineWidth', 2, 'Color', [1 0.2 0.6]);

  if ~isempty(zero)
      h_zero = plot(real(zero), imag(zero), 'o', 'MarkerSize', 15, 'LineWidth', 2, 'Color', [0.4 0.2 0.4]);
      legend('Polos', 'Zeros');
  else
      legend('Polos');
  end
  hold off;

  grid on;
  title(sprintf('Polos e Zeros do sistema %s', sys_name));
  xlabel('Eixo Real');
  ylabel('Eixo Imaginário');

  exportgraph(sprintf('graph-3-%s-pzmap', letter), can_generate);
end

t = 0:0.1:60;

sys = tf([1], [3, 1]);

temporal_response(t, sys, '1 / (3s + 1)', 'a', GENERATE_GRAPHS);

% Questão 3b - pade

[num, den] = padecoef(5, 1);

delay_sys = tf(num, den);

base_sys = tf([1], [3, 1]);

sys = delay_sys * base_sys;

temporal_response(t, sys, '1 / (3s + 1) * e^{-5s}', 'b', GENERATE_GRAPHS);

% Questão 3c

wn = 1;
zetas = [0.35, 0.7, 1.35];

for i = 1:length(zetas)

  sys = tf([wn^2], [1, 2 * zetas(i) * wn, wn^2]);

  sub_letter = sprintf('c-%d', i);

  name = sprintf('1 / (s^2 + %.2fs + 1)', 2 * zetas(i) * wn);

  temporal_response(t, sys, name, sub_letter, GENERATE_GRAPHS);
end

% Quetão 4

num = 1;
den = conv(conv([1 2], [1 2]), [1 2]);
sys = tf(num, den);

t = 0:0.01:6;

% Quetão 4a e b

[y, t_out] = step(sys, t);

y_analitic = dcgain(sys);
fprintf('Valor Final Analítico (Questão 4a): %.4f (1/8 = 0.125)\n', y_analitic);

figure('NumberTitle', 'off', 'Name', 'Questao 4a - Resposta ao Degrau', 'Position', [171, 117, 1025, 576]);
hold on;

plot(t_out, y, 'b-', 'LineWidth', 2, 'DisplayName', 'Resposta y(t)');

yline_val = y_analitic * ones(size(t_out));
plot(t_out, yline_val, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Valor Final (y_{ss} = %.3f)', y_analitic));

grid on;
title('Questão 4a: Resposta ao Degrau para G(s) = 1/(s+2)^3');
xlabel('Tempo (s)');
ylabel('Amplitude');
legend('location', 'southeast');
hold off;

exportgraph('graph-4a', GENERATE_GRAPHS);

% Questão 4c

poles = 1:1:8;

legend_names = cell(1, length(poles));
colors = {'#ff0000', '#00ff00', '#0000ff', '#ffff00', '#00ffff', '#ff00ff', '#ff9955', '#55ff99'};
figure('NumberTitle', 'off', 'Name', 'Questao 4c - Resposta ao Degrau com Multiplos Polos', 'Position', [171, 117, 1025, 576]);
hold on;

for i = 1:length(poles)
  num = 1;
  den = 1;

  for j = 1:poles(i)
    den = conv([1 1], den);
  end

  legend_names{i} = sprintf('Polo de ordem %d', poles(i));

  sys = tf(num, den);
  [y, t_out] = step(sys, t);

  plot(t_out, y, 'LineWidth', 2, 'Color', colors{i});
end

grid on;
title('Questão 4c: Resposta ao Degrau para G(s) com polos variando de 1 a 8');
xlabel('Tempo (s)');
ylabel('Amplitude');

legend(legend_names, 'location', 'southeast');
hold off;

exportgraph('graph-4c', GENERATE_GRAPHS);

% Quetão 5:

num = 25;
den = [1 2 25];
sys = tf(num, den);

p3_val = [0.5, 1, 2, 10];

t = 0:0.01:6;

figure('NumberTitle', 'off', 'Name', 'Questao 5 - Efeito do Terceiro Polo', 'Position', [171, 117, 1025, 576]);
hold on;

[y_orig, t_orig] = step(sys, t);
plot(t_orig, y_orig, 'k--', 'LineWidth', 2, 'DisplayName', 'Original (2ª Ordem)');

cores = {'r', 'g', 'b', 'm'};

for i = 1:length(p3_val)
    p3 = p3_val(i);
    sys_polo3 = sys * tf(p3, [1 p3]);

    [y, t_out] = step(sys_polo3, t);

    rotulo = sprintf('p3 = -%.1f', p3);
    plot(t_out, y, cores{i}, 'LineWidth', 1.5, 'DisplayName', rotulo);
end

grid on;
title('Questão 5: Efeito da Adição do Terceiro Polo no Sistema de 2ª Ordem');
xlabel('Tempo (s)');
ylabel('Amplitude');
legend('location', 'southeast');
hold off;

exportgraph('graph-5', GENERATE_GRAPHS);

