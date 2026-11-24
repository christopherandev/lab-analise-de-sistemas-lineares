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
