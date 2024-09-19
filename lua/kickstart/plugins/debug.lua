-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
    },

    -- Installs the debug adapters for you
    {
      'williamboman/mason.nvim',
      build = ':MasonUpdate', -- Optional, updates Mason when syncing
    },

    {
      'jay-babu/mason-nvim-dap.nvim',
      dependencies = { 'williamboman/mason.nvim', 'mfussenegger/nvim-dap' },
    },

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',

    {
      'microsoft/vscode-js-debug',
      build = 'npm i --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out',
    },

    {
      'mxsdev/nvim-dap-vscode-js',
      dependencies = { 'mfussenegger/nvim-dap' },
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'js-debug-adapter',
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })

    -- DAP key mappings
    vim.keymap.set('n', '<F5>', require('dap').continue) -- Start/continue debugging
    vim.keymap.set('n', '<F10>', require('dap').step_over) -- Step over a line
    vim.keymap.set('n', '<F11>', require('dap').step_into) -- Step into a function
    vim.keymap.set('n', '<F12>', require('dap').step_out) -- Step out of a function
    vim.keymap.set('n', '<leader>b', require('dap').toggle_breakpoint) -- Toggle a breakpoint
    vim.keymap.set('n', '<leader>B', function()
      require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end) -- Set conditional breakpoint
    vim.keymap.set('n', '<leader>dr', require('dap').repl.open) -- Open REPL
    vim.keymap.set('n', '<leader>dl', require('dap').run_last) -- Run last debug configuration

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    -- DAP-UI key mappings
    vim.keymap.set('n', '<leader>dui', dapui.toggle) -- Toggle the DAP UI
    vim.keymap.set('n', '<leader>dq', require('dap').terminate) -- End the debug session
    vim.keymap.set('n', '<leader>de', dapui.eval) -- Evaluate the expression under the cursor
    vim.keymap.set('v', '<leader>de', function() -- Evaluate a visual selection
      dapui.eval(vim.fn.visualmode())
    end)

    -- Open/close individual DAP UI elements
    vim.keymap.set('n', '<leader>do', function()
      dapui.open()
    end) -- Open DAP UI
    vim.keymap.set('n', '<leader>dc', function()
      dapui.close()
    end) -- Close DAP UI

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- Setup for nvim-dap-vscode-js
    require('dap-vscode-js').setup {
      -- node_path = 'node', -- Path to node executable
      debugger_path = vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug', -- Path to vscode-js-debug
      adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'node' }, -- Supported adapters
    }
  end,
}
