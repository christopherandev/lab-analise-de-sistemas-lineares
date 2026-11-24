clear; clc; close all;

%% Parte 2

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

% --- Leitura do arquivo dados_amostra_ti_ac.txt ---
if exist('dados_amostra_ti_ac.txt', 'file')
    dados_amostra_ti_ac = dlmread('dados_amostra_ti_ac.txt');
else
    error('O arquivo "dados_amostra_ti_ac.txt" não foi encontrado no diretório atual.');
end

fc = 0.0488;
tempo = dados_amostra_ti_ac(:,1);
ti = dados_amostra_ti_ac(:,2) * fc;
ac = dados_amostra_ti_ac(:,3) * fc;

phi = [ti(1:end-1), ac(1:end-1)];

theta = pinv(phi) * ti(2:end);

% Garantindo o tamanho correto para o vetor y_pred baseado no tamanho de tempo
N = length(tempo);
y_pred = zeros(1, N);
y_pred(1) = ti(1);

for k = 2:N
    y_pred(k) = theta(1) * y_pred(k-1) + theta(2) * ac(k-1);
end

figure(1)
hold on
stem(tempo, y_pred, 'LineWidth', 1.75)
stem(tempo, ti, 'LineWidth', 1.75)
legend('ypred', 'ti')
hold off

exportgraph('graph-1', GENERATE_GRAPHS);

figure(2)
hold on
plot(tempo, y_pred, 'LineWidth', 1.75)
plot(tempo, ti, 'LineWidth', 1.75)
legend('ypred', 'ti')
hold off

exportgraph('graph-2', GENERATE_GRAPHS);

% Ajuste de dimensões para o cálculo do erro e somatório (transposição segura)
ti_col = ti(:)';
y_pred_col = y_pred(:)';

J = sum((ti_col - y_pred_col).^2);

figure(3)
erro = ti_col - y_pred_col;
plot(tempo, erro, 'LineWidth', 1.75)
title('Erro de Predição')
xlabel('Tempo')
ylabel('Erro')

exportgraph('graph-3', GENERATE_GRAPHS);
