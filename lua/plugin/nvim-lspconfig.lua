return {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',           -- Automatically install LSPs to stdpath for neovim
        'williamboman/mason-lspconfig.nvim', -- Useful status updates for LSP
        -- NOTE `opts = {}` is the same as calling `require('fidget').setup({})`
        {
            'j-hui/fidget.nvim',
            version = 'legacy'
        }, -- Additional lua configuration, makes nvim stuff amazing!
        'folke/neodev.nvim'
    }
}
