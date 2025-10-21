{ lib, pkgs, config, ... }:

{
    programs.tmux = {
        enable = true;
        terminal = "screen-256color";
        prefix = "C-space";
        keyMode = "vi";
        baseIndex = 1;
        escapeTime = 10;    
        mouse = true;
        focusEvents = true;
        plugins = with pkgs; [ 
            tmuxPlugins.vim-tmux-navigator
            tmuxPlugins.yank 
            tmuxPlugins.tmux-floax
            {
                plugin = tmuxPlugins.tokyo-night-tmux;
                extraConfig = ''
                    # number styles
                    set -g @tokyo-night-tmux_window_id_style roman 
                    set -g @tokyo-night-tmux_pane_id_style hsquare
                    set -g @tokyo-night-tmux_zoom_id_style dsquare

                    # widget
                    set -g @tokyo-night-tmux_show_netspeed 1
                    set -g @tokyo-night-tmux_netspeed_iface "eth0" 
                    set -g @tokyo-night-tmux_netspeed_showip 1      
                    set -g @tokyo-night-tmux_netspeed_refresh 1     
                '';
            }
            {
                plugin = tmuxPlugins.resurrect;
                extraConfig = ''
                    set -g @resurrect-strategy-nvim 'session'
                    set -g @resurrect-capture-pane-contents 'on'
                '';
            }
            {
                plugin = tmuxPlugins.continuum;
                extraConfig = ''
                    set -g @continuum-restore 'on'
                    set -g @continuum-save-internal '60'
                '';
            }
        ];
        extraConfig = ''
            set -ag terminal-overrides ",*256col*:RGB"
            unbind %
            bind | split-window -h -c "#{pane_current_path}"

            unbind '"'
            bind - split-window -v -c "#{pane_current_path}"

            unbind r
            bind r source-file "${config.xdg.configHome}/tmux/tmux.conf"

            bind j resize-pane -D 5
            bind k resize-pane -U 5
            bind l resize-pane -R 5
            bind h resize-pane -L 5

            bind -r m resize-pane -Z

            bind-key -T copy-mode-vi 'v' send -X begin-selection 
            bind-key -T copy-mode-vi 'C-q' send -X rectangle-toggle
            bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
            bind-key -T copy-mode-vi 'Y' send -X copy-line

            unbind ] 
            unbind -T copy-mode-vi MouseDragEnd1Pane
        '';
    };
}
