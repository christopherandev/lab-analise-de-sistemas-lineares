===================================================================
 1. MODELAGEM DA PLANTA EM MALHA ABERTA
===================================================================
Funcao de Transferencia da Planta G(s):

Transfer function 'G_MA' from input 'u1' to output ...

           1
 y1:  -----------
      1.5 s^2 + s

Continuous-time model.
Polos da Planta em Malha Aberta:
  -0.6667
        0
===================================================================
 2. CONTROLADOR PROPORCIONAL E LUGAR DAS RAÍZES
===================================================================
Funcao de Transferencia em Malha Fechada (com Kp):

Transfer function 'G_MF_P' from input 'u1' to output ...

             2
 y1:  ---------------
      1.5 s^2 + s + 2

Continuous-time model.
===================================================================
 3. ANÁLISE DE RESPOSTA TRANSITÓRIA E DESEMPENHO
===================================================================
Especificacoes de Desempenho (stepinfo):
    RaiseTime = [](0x0)
    RiseTime = 1.1532
    TransientTime = 11.793
    SettlingTime = 11.793
    SettlingMin = 0.8496
    SettlingMax = 1.3835
    Overshoot = 38.349
    Undershoot = 0
    Peak = 1.3835
    PeakTime = 2.9730
    StaticGain = 1
    InitialJump = 0
===================================================================
 4. CRITÉRIO DE ROUTH-HURWITZ
===================================================================

------------------ TABELA DE ROUTH ------------------
   1.5000   2.0000
   1.0000        0
   2.0000        0
-------------------------------------------------------
Resultado Routh: O sistema em malha fechada e ESTAVEL.

===================================================================
 5. RESPOSTA EM FREQUÊNCIA E ESTABILIDADE RELATIVA
===================================================================
Margem de Ganho (Gm): Inf dB (ou Inf)
Margem de Fase (Pm): 32.10 graus
Frequencia de Cruzamento de Ganho (Wcg): NaN rad/s
Frequencia de Cruzamento de Fase (Wcp): 1.0628 rad/s
===================================================================
 6. SISTEMAS DE FASE NÃO-MÍNIMA E ATRASO DE TRANSPORTE
===================================================================
