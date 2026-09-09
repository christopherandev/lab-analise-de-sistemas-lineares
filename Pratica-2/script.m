clc; close all; clear;

GENERATE_GRAPHS = true;

function exportgraph(filename, generate)

   if !generate
        return;
    endif

    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperSize', [12.8, 7.2]);
    set(gcf, 'PaperPosition', [0, 0, 12.8, 7.2]);

    print(gcf, fullfile(pwd, filename), '-dpng', '-r600');
end

function formatPlot(plotTitle, letter, y, t0, u, t)
  hold on;
  plot(t0, y, 'Color', 'b', 'Linewidth', 2.15);
  xlabel('Tempo (s)');
  ylabel('Amplitude');
  plot(t, u, '--', 'Color', 'r', 'Linewidth', 2.15);
  title(plotTitle);
  legend('Resposta do sistema', 'Entrada');
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

exportgraph('graph-2', GENERATE_GRAPHS);

% Quetão 3a

t = 0:0.1:60;

impulse   = @(t, k = 0) (t == k);
ustep     = @(t) (ones(size(t)));
ramp      = @(t) (t .* ones(size(t)));
parabolic = @(t) (t .^2 .* ones(size(t)));

sys = tf([1], [3, 1]);

figure('NumberTitle', 'off', 'Name', 'Questão 3a - Resposta Temporal', 'Position', [171, 117, 1025, 576]);

subplot(2, 2, 1);
[y, t0] = lsim(sys, impulse(t), t);
formatPlot('Resposta ao Impulso', 'a', y, t0, impulse(t), t);

subplot(2, 2, 2);
[y, t0] = lsim(sys, ustep(t), t);
formatPlot('Resposta ao Degrau', 'a', y, t0, ustep(t), t);

subplot(2, 2, 3);
[y, t0] = lsim(sys, ramp(t), t);
formatPlot('Resposta à Rampa', 'a', y, t0, ramp(t), t);

subplot(2, 2, 4);
[y, t0] = lsim(sys, parabolic(t), t);
formatPlot('Resposta à Parábola', 'a', y, t0, parabolic(t), t);

exportgraph('graph-3a-1', GENERATE_GRAPHS);

figure('NumberTitle', 'off', 'Name', 'Questão 3a - pzmap', 'Position', [171, 117, 1025, 576]);

[pole, zero] = pzmap(sys);

hold on;
h_pole = plot(real(pole), imag(pole), 'x', 'MarkerSize', 12, 'LineWidth', 2, 'Color', '#ff3399');

if ~isempty(zero)
    h_zero = plot(real(zero), imag(zero), 'o', 'MarkerSize', 12, 'LineWidth', 2, 'Color', '#663366');
    legend('Polos', 'Zeros');
    disp(sprintf('Polo: %.2f | Zero: %.2f', pole, zero));

else
    legend('Polos');
    disp(sprintf('Polo: %.2f | Zero: -/-', pole));

end

hold off;

grid on;
title('Diagrama de Polos e Zeros');
xlabel('Eixo Real');
ylabel('Eixo Imaginário');

exportgraph('graph-3a-2', GENERATE_GRAPHS);

% Quetão 3b - pade

t = 0:0.1:60;

impulse   = @(t, k = 0) (t == k);
ustep     = @(t) (ones(size(t)));
ramp      = @(t) (t .* ones(size(t)));
parabolic = @(t) (t .^2 .* ones(size(t)));

[num, den] = padecoef(5, 1);

delay_sys = tf(num, den);

base_sys = tf([1], [1, 3]);

sys = delay_sys * base_sys;

figure('NumberTitle', 'off', 'Name', 'Questão 3b - Resposta Temporal', 'Position', [171, 117, 1025, 576]);

subplot(2, 2, 1);
[y, t0] = lsim(sys, impulse(t), t);
formatPlot('Resposta ao Impulso', 'a', y, t0, impulse(t), t);

subplot(2, 2, 2);
[y, t0] = lsim(sys, ustep(t), t);
formatPlot('Resposta ao Degrau', 'a', y, t0, ustep(t), t);

subplot(2, 2, 3);
[y, t0] = lsim(sys, ramp(t), t);
formatPlot('Resposta à Rampa', 'a', y, t0, ramp(t), t);

subplot(2, 2, 4);
[y, t0] = lsim(sys, parabolic(t), t);
formatPlot('Resposta à Parábola', 'a', y, t0, parabolic(t), t);

exportgraph('graph-3b-1', GENERATE_GRAPHS);

figure('NumberTitle', 'off', 'Name', 'Questão 3b - pzmap', 'Position', [171, 117, 1025, 576]);

[pole, zero] = pzmap(sys);

hold on;
h_pole = plot(real(pole), imag(pole), 'x', 'MarkerSize', 12, 'LineWidth', 2, 'Color', '#ff3399');

if ~isempty(zero)
    h_zero = plot(real(zero), imag(zero), 'o', 'MarkerSize', 12, 'LineWidth', 2, 'Color', '#663366');
    legend('Polos', 'Zeros');
    disp(sprintf('Polo: %.2f | Zero: %.2f', pole, zero));

else
    legend('Polos');
    disp(sprintf('Polo: %.2f | Zero: -/-', pole));

end

hold off;

grid on;
title('Diagrama de Polos e Zeros');
xlabel('Eixo Real');
ylabel('Eixo Imaginário');

exportgraph('graph-3b-2', GENERATE_GRAPHS);

% Quetão 3c

t = 0:0.1:60;

wn = 1;
zetas = [ 0.35, 0.7, 1.35]

impulse   = @(t, k = 0) (t == k);
ustep     = @(t) (ones(size(t)));
ramp      = @(t) (t .* ones(size(t)));
parabolic = @(t) (t .^2 .* ones(size(t)));

for i = 1:length(zetas)

  sys = tf([wn^2], [1, 2 * zetas(i) * wn, wn^2]);

  figure('NumberTitle', 'off', 'Name', sprintf('Questão 3c - Resposta Temporal para zeta = %.2f', zetas(i)), 'Position', [171, 117, 1025, 576]);

  subplot(2, 2, 1);
  [y, t0] = lsim(sys, impulse(t), t);
  formatPlot('Resposta ao Impulso', 'a', y, t0, impulse(t), t);

  subplot(2, 2, 2);
  [y, t0] = lsim(sys, ustep(t), t);
  formatPlot('Resposta ao Degrau', 'a', y, t0, ustep(t), t);

  subplot(2, 2, 3);
  [y, t0] = lsim(sys, ramp(t), t);
  formatPlot('Resposta à Rampa', 'a', y, t0, ramp(t), t);

  subplot(2, 2, 4);
  [y, t0] = lsim(sys, parabolic(t), t);
  formatPlot('Resposta à Parábola', 'a', y, t0, parabolic(t), t);

  exportgraph(sprintf("graph-3c-1-%d", i), GENERATE_GRAPHS);

  figure('NumberTitle', 'off', 'Name', sprintf('Questão 3c - pzmap para zeta = %.2f', zetas(i)), 'Position', [171, 117, 1025, 576]);

  [pole, zero] = pzmap(sys);

  hold on;
  h_pole = plot(real(pole), imag(pole), 'x', 'MarkerSize', 12, 'LineWidth', 2, 'Color', '#ff3399');

  if ~isempty(zero)
      h_zero = plot(real(zero), imag(zero), 'o', 'MarkerSize', 12, 'LineWidth', 2, 'Color', '#663366');
      legend('Polos', 'Zeros');
      disp(sprintf('Polo: %.2f | Zero: %.2f', pole, zero));

  else
      legend('Polos');
      disp(sprintf('Polo: %.2f | Zero: -/-', pole));

  end

  hold off;

  grid on;
  title('Diagrama de Polos e Zeros');
  xlabel('Eixo Real');
  ylabel('Eixo Imaginário');

  exportgraph(sprintf("graph-3c-2-%d", i), GENERATE_GRAPHS);

end


% Quetão 4

num = 1;
den = conv(conv([1 2], [1 2]), [1 2]);
sys = tf(num, den);

t = 0:0.01:6;

[y, t_out] = step(sys, t);

y_analitic = dcgain(sys);
fprintf('Valor Final Analítico (Questão 4a): %.4f (1/8 = 0.125)\n', y_analitic);

figure('NumberTitle', 'off', 'Name', 'Questao 4a - Resposta ao Degrau');
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

exportgraph('graph-4', GENERATE_GRAPHS);

% Quetão 5:

num = 25;
den = [1 2 25];
sys = tf(num, den);

p3_val = [0.5, 1, 2, 10];

t = 0:0.01:6;

figure('NumberTitle', 'off', 'Name', 'Questao 5 - Efeito do Terceiro Polo');
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
