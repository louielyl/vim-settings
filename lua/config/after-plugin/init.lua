-- print("after plugins")

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, {
            buffer = bufnr,
            desc = desc
        })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    -- nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', function()
        require('telescope.builtin').lsp_references({ include_declaration = false })
    end, '[G]oto [R]eferences')
    -- nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    -- nmap('<C-K>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, {
        desc = 'Format current buffer with LSP'
    })
    nmap('<leader>f', vim.lsp.buf.format, 'LSP [F]ormat')

    if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, bufnr)
    end
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
    lua_ls = {
        Lua = {
            workspace = {
                checkThirdParty = false
            },
            telemetry = {
                enable = false
            }
        }
    }
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- nvim-ufo setup
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers)
}

mason_lspconfig.setup_handlers { function(server_name)
    require('lspconfig')[server_name].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = servers[server_name]
    }
end }

require('ufo').setup()

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

luasnip.config.setup {}

vim.opt.completeopt = { "menu", "menuone", "noselect" }

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-u>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item({ count = 2 })
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ count = 2 })
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' })
    },
    sources = { {
        name = 'nvim_lsp'
    }, {
        name = 'luasnip'
    } }
}

-- Plugin menus

-- git blame
vim.keymap.set('n', '<leader>pgb', "<CMD>call gitblame#echo()<CR>", { desc = "[G]it [B]lame" })

-- Lazygit
vim.keymap.set('n', '<leader>plg', "<CMD>LazyGit<CR>", { desc = "[L]azy [G]it" })
vim.keymap.set('n', '<leader>plc', "<CMD>LazyGitConfig<CR>", { desc = "[L]azy Git [C]onfig" })

-- Spectre setup
vim.keymap.set('n', '<leader>ps', '<CMD>lua require("spectre").open()<CR>', { desc = "[S]pectre" })

-- Diffview setup
vim.keymap.set('n', '<leader>pdo', "<CMD>DiffviewOpen origin/main<CR>", { desc = "[O]pen" })
vim.keymap.set('n', '<leader>pdf', "<CMD>DiffviewFileHistory %<CR>", { desc = "[F]ile History" })
vim.keymap.set('n', '<leader>pdc', "<CMD>DiffviewClose<CR>", { desc = "[C]lose" })
vim.keymap.set('n', '<leader>pdF', "<CMD>DiffviewToggleFiles<CR>", { desc = "[T]oggle Files" })
vim.keymap.set('n', '<leader>pdF', "<CMD>DiffviewFocusFiles<CR>", { desc = "[F]ocus Files" })
vim.keymap.set('n', '<leader>pdr', "<CMD>DiffviewRefresh<CR>", { desc = "[R]efresh" })
vim.keymap.set('n', '<leader>pdl', "<CMD>DiffviewLog<CR>", { desc = "[L]og" })

-- Lazy vim
vim.keymap.set("n", "<leader>plv", "<CMD>:Lazy<CR>", { desc = "[L]azy [V]im" })

-- Mason
vim.keymap.set("n", "<leader>pm", "<CMD>Mason<CR>", { desc = "[M]ason" })

-- Alpha
vim.keymap.set("n", "<leader>pa", "<CMD>Alpha<CR>", { desc = "[A]lpha" })

-- Plugin setup

-- ale prettier setup
-- vim.g.ale_fixers = {'prettier', 'eslint', 'lua-format' }

-- vim-smoothie setup
-- vim.g.smoothie_update_interval = ??
vim.g.smoothie_base_speed = 2000

-- which-key setup
local wk = require("which-key")
wk.register({
    ["<leader>b"] = { name = "+[B]uffer" },
    ["<leader>C"] = { name = "+[C]ustom" },
    ["<leader>c"] = { name = "+[C]ode action" },
    ["<leader>d"] = { name = "+[D]ocument" },
    ["<leader>h"] = { name = "+[G]it Gutter " },
    ["<leader>l"] = { name = "+[L]ine number" },
    ["<leader>r"] = { name = "+[R]ename " },
    ["<leader>w"] = { name = "+[W]orkspace" },
    ["<leader>x"] = { name = "+[T]rouble" },
    ["<leader>p"] = { name = "+[P]lugin" },
    ["<leader>pd"] = { name = "+[D]iffview" },
    ["<leader>pg"] = { name = "+[G]it" },
    ["<leader>pl"] = { name = "+[L]azy git" },
    ["<leader>s"] = { name = "+[S]earch" },
}, { mode = "n" })
wk.register({
    ["<leader>K"] = { name = "+[C]hange Case" },
}, { mode = "v" })

