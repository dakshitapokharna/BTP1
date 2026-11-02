function plot_pair(ax, t, y, paperfile, col, lab, ls)
% Plot paper (digitized, thick light dashed) and our result (solid) on axes ax.
% paperfile = '' -> no paper curve for this case.
axes(ax); hold on;
lightcol = 1 - 0.45*(1 - col);          % lighter shade of same hue
if ~isempty(paperfile)
    P = dlmread(fullfile('paper_data', paperfile));
    plot(P(:,1), P(:,2), '--', 'Color', lightcol, 'LineWidth', 3.5, ...
         'DisplayName', [lab ' - paper']);
end
plot(t, y, ls, 'Color', col, 'LineWidth', 1.4, 'DisplayName', [lab ' - our code']);
end
