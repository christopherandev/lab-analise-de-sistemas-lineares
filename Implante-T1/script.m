% =========================================================================
% TRABALHO DE ELETRODINAMICA - ALIMENTACAO DE IMPLANTE MEDICO
% =========================================================================
clear; clc; close all;

GENERATE_GRAPHS = true;

function exportgraph(filename, generate)

   if !generate
        return;
    endif

    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperSize', [12.8, 7.2]);
    set(gcf, 'PaperPosition', [0, 0, 12.8, 7.2]);

    print(gcf, fullfile(pwd, filename), '-dpng', '-r100');
end

% -------------------------------------------------------------------------
% PARAMETROS INICIAIS (Eqs e especificacoes do trabalho)
% -------------------------------------------------------------------------
S0 = 20;               % Densidade de potencia em z=0 (W/m^2)
mu0 = 4*pi*1e-7;       % Permeabilidade do vacuo (H/m)
eps0 = 8.854e-12;      % Permissividade do vacuo (F/m)
rho = 1050;            % Densidade do tecido (kg/m^3)
Ac = 1e-4;             % Area de captacao (m^2) - 1 cm^2
eta_c = 0.3;           % Eficiencia do implante (30%)
Pmin = 50e-6;          % Potencia minima requerida (W)
l_max = 30e-3;         % Maior dimensao da antena (m)
SARmax = 2;            % Limite SAR (W/kg)

% Dados das Frequencias (Tabela 1)
f = [100e6, 433e6, 915e6, 2.45e9]; % Frequencias (Hz)
er = [66, 57, 55, 52.7];           % Permissividades relativas
sig = [0.70, 0.80, 0.95, 1.74];    % Condutividades (S/m)

nomes_freq = {'100 MHz', '433 MHz', '915 MHz', '2.45 GHz'};

% Dominio espacial (0 a 10 cm)
z = linspace(0, 0.1, 500);

% Matrizes para guardar resultados para o Mapa de Viabilidade
% Linhas = Frequencias | Colunas = Profundidades (2, 5, 8, 10 cm)
z_map_test = [0.02, 0.05, 0.08, 0.10];
mapa_viabilidade = cell(4, 4);

fprintf('=========================================================\n');
fprintf(' INICIANDO CALCULOS DAS SECOES 1.4 A 1.8\n');
fprintf('=========================================================\n\n');

for i = 1:length(f)
    fprintf('>>> ANALISANDO FREQUENCIA: %s <<<\n', nomes_freq{i});
    fprintf('---------------------------------------------------------\n');

    % --- SECAO 1.4: Parametros de Propagacao ---
    w = 2 * pi * f(i);
    mu = 1 * mu0;
    eps = er(i) * eps0;

    % Constante de propagacao e impedancia intrinseca
    gamma = sqrt(1j * w * mu * (sig(i) + 1j * w * eps));
    alpha = real(gamma);
    beta = imag(gamma);
    eta = sqrt((1j * w * mu) / (sig(i) + 1j * w * eps));

    alpha_dB_cm = alpha * 8.686 / 100; % Convertendo Np/m para dB/cm
    lambda = (2 * pi) / beta;
    vf = w / beta;
    delta_E = 1 / alpha;
    delta_P = 1 / (2 * alpha);
    l_ant = lambda / 4;

    fprintf('1.4) Parametros de Propagacao:\n');
    fprintf('  - Atenuacao (alfa): %.4f Np/m (%.4f dB/cm)\n', alpha, alpha_dB_cm);
    fprintf('  - Fase (beta): %.4f rad/m\n', beta);
    fprintf('  - Comprimento de Onda (lambda): %.4f m\n', lambda);
    fprintf('  - Velocidade de Fase (vf): %.2e m/s\n', vf);
    fprintf('  - Impedancia Intrinseca (eta): %.2f + j(%.2f) Ohms\n', real(eta), imag(eta));
    fprintf('  - Prof. de Penetracao (delta_E): %.4f m\n', delta_E);
    fprintf('  - Prof. Potencia (delta_P): %.4f m\n', delta_P);
    fprintf('  - Antena Estimada (l_ant): %.4f m\n\n', l_ant);

    % --- SECAO 1.5 e 1.6: Simulacao dos Campos e Potencia ---
    % Calculando E0 a partir de S(0)
    theta_eta = angle(eta);
    E0 = sqrt((2 * S0 * abs(eta)) / cos(theta_eta));

    E_z_mag = E0 * exp(-alpha * z);
    H_z_mag = (E0 / abs(eta)) * exp(-alpha * z);
    S_z = S0 * exp(-2 * alpha * z);
    P_imp = eta_c * Ac * S_z;

    % Encontrando z_max onde P_imp >= P_min
    idx_pmin = find(P_imp >= Pmin, 1, 'last');
    if isempty(idx_pmin)
        zmax = 0;
    else
        zmax = z(idx_pmin);
    end
    fprintf('1.6) Potencia no Implante:\n');
    fprintf('  - Profundidade Maxima de Funcionamento (z_max): %.4f m\n\n', zmax);

    % --- SECAO 1.7: Potencia Absorvida e SAR ---
    pv = (sig(i) / 2) * (E_z_mag.^2);
    SAR = pv / rho;
    SAR_max_val = max(SAR);

    % Profundidade onde SAR cai para 10%
    idx_sar10 = find(SAR <= 0.1 * SAR_max_val, 1, 'first');
    z_sar10 = z(idx_sar10);

    fprintf('1.7) Absorcao pelo Tecido (SAR):\n');
    fprintf('  - SAR Maximo (superficie): %.4f W/kg\n', SAR_max_val);
    fprintf('  - Profundidade 10%% SAR: %.4f m\n', z_sar10);
    if SAR_max_val <= SARmax
        fprintf('  - Limite SAR: ATENDIDO (<= 2 W/kg)\n');
    else
        fprintf('  - Limite SAR: VIOLADO (> 2 W/kg)\n');
    end

    % Verificacao numerica da conservacao de potencia
    P_dissipada_total = trapz(z, pv);
    P_diferenca_S = S_z(1) - S_z(end);
    erro_perc = abs((P_dissipada_total - P_diferenca_S) / P_diferenca_S) * 100;
    fprintf('  - Verificacao Conservacao Energia (Erro): %.4e %%\n\n', erro_perc);

    % --- SECAO 1.8: Preenchendo Mapa de Viabilidade ---
    for k = 1:4
        z_atual = z_map_test(k);
        P_imp_atual = eta_c * Ac * S0 * exp(-2 * alpha * z_atual);
        SAR_atual = ((sig(i) / 2) * (E0 * exp(-alpha * z_atual))^2) / rho;

        % Usando chaves {i, k} para armazenar o texto dentro da célula:
        if P_imp_atual < Pmin
            mapa_viabilidade{i,k} = 'Potencia Insuficiente';
        elseif SAR_atual > SARmax
            mapa_viabilidade{i,k} = 'Absorcao Excessiva';
        elseif l_ant > l_max
            mapa_viabilidade{i,k} = 'Antena Incompativel';
        else
            mapa_viabilidade{i,k} = 'Viavel';
        end
    end

    % ---------------------------------------------------------------------
    % PLOTS (Campos, Potencia, SAR)
    % ---------------------------------------------------------------------
    figure('Name', sprintf('Resultados - %s', nomes_freq{i}), 'NumberTitle', 'off', 'Position', [100, 100, 900, 600]);

    subplot(2,2,1);
    plot(z*100, E_z_mag, 'b', 'LineWidth', 2);
    title('|E(z)| (V/m)'); xlabel('z (cm)'); ylabel('Magnitude'); grid on;

    subplot(2,2,2);
    plot(z*100, H_z_mag, 'r', 'LineWidth', 2);
    title('|H(z)| (A/m)'); xlabel('z (cm)'); ylabel('Magnitude'); grid on;

    subplot(2,2,3);
    plot(z*100, P_imp*1e6, 'k', 'LineWidth', 2); hold on;

    x_limits = xlim(); % Gets [min_x, max_x] of the current plot
    line(x_limits, [Pmin*1e6, Pmin*1e6], "linestyle", "--", "color", "r");

    %yline(Pmin*1e6, 'r--', 'P_{min}');
    title('Potencia no Implante (\muW)'); xlabel('z (cm)'); ylabel('P_{imp}'); grid on;

    subplot(2,2,4);
    plot(z*100, SAR, 'm', 'LineWidth', 2); hold on;

    x_limits = xlim(); % Gets [min_x, max_x] of the current plot
    line(x_limits, [SARmax, SARmax], "linestyle", "--", "color", "r");

    %yline(SARmax, 'r--', 'SAR_{max}');

    title('SAR (W/kg)'); xlabel('z (cm)'); ylabel('SAR'); grid on;

    exportgraph(sprintf('plot-%d-MHz', f(i) / 1e6), GENERATE_GRAPHS);

    % ---------------------------------------------------------------------
    % GERANDO A ANIMACAO (.GIF)
    % ---------------------------------------------------------------------
    fprintf('  >> Gerando Animacao (GIF) para %s... Aguarde.\n', nomes_freq{i});
    fig_anim = figure('Name', sprintf('Animacao - %s', nomes_freq{i}), 'Visible', 'off');
    filename_gif = sprintf('animacao_onda_%dMHz.gif', f(i)/1e6);

    t_frames = linspace(0, 2/f(i), 30); % 30 frames cobrindo 2 periodos
    for frm = 1:length(t_frames)
        t = t_frames(frm);
        E_inst = E0 * exp(-alpha * z) .* cos(w * t - beta * z);

        plot(z*100, E_inst, 'b', 'LineWidth', 2);
        hold on;
        plot(z*100, E_z_mag, 'r--', 'LineWidth', 1); % Envelope
        plot(z*100, -E_z_mag, 'r--', 'LineWidth', 1);
        hold off;

        ylim([-E0*1.1, E0*1.1]);
        title(sprintf('Campo Eletrico Instantaneo - %s', nomes_freq{i}));
        xlabel('Profundidade z (cm)'); ylabel('E(z,t) [V/m]');
        grid on;

        % Capturando o frame e adicionando ao GIF
        frame = getframe(fig_anim);
        im = frame2im(frame);

        % ALTERAÇÃO AQUI: Removido o número 256 para compatibilidade com o Octave
        [imind, cm] = rgb2ind(im);

        if frm == 1
            imwrite(imind, cm, filename_gif, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
        else
            imwrite(imind, cm, filename_gif, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
        end
    end
    close(fig_anim);
    fprintf('  >> GIF salvo como %s\n\n', filename_gif);
    fprintf('---------------------------------------------------------\n');
end

% --- IMPRIMINDO MAPA DE VIABILIDADE (SECAO 1.8) ---
fprintf('\n=========================================================\n');
fprintf(' 1.8) MAPA DE VIABILIDADE \n');
fprintf('=========================================================\n');
fprintf('%-12s | %-20s | %-20s | %-20s | %-20s\n', 'Freq', 'z = 2 cm', 'z = 5 cm', 'z = 8 cm', 'z = 10 cm');
fprintf(repmat('-', 1, 105));
fprintf('\n');
for i = 1:4
    fprintf('%-12s | %-20s | %-20s | %-20s | %-20s\n', ...
        nomes_freq{i}, mapa_viabilidade{i,1}, mapa_viabilidade{i,2}, mapa_viabilidade{i,3}, mapa_viabilidade{i,4});
end
fprintf('=========================================================\n');
