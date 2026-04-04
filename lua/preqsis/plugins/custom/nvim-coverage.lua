return {
	dir = "~/Projects/personal/neovim/nvim-coverage",
	config = function()
		require("nvim-coverage").setup({
			-- Adapter-specific configuration
			adapters = {
				coverage_py = {
					coverage_file = "coverage.json",
					coverage_db = ".coverage",
					coverage_command = "coverage",
					auto_generate_json = true,
				},
			},

			-- Global UI settings
			highlight = {
				missing_lines_bg = "#4a1a1a",
			},
			auto_refresh = true,
		})
	end,
	cmd = {
		"CoverageToggle",
		"CoverageSummary",
		"CoverageReload",
		"CoverageReport",
		"CoverageClear",
	},
	keys = {
		{ "<leader>cv", "<cmd>CoverageToggle<cr>", desc = "Coverage: Toggle" },
		{ "<leader>cs", "<cmd>CoverageSummary<cr>", desc = "Coverage: Summary" },
		{ "<leader>cr", "<cmd>CoverageReload<cr>", desc = "Coverage: Reload" },
		{ "<leader>ct", "<cmd>CoverageReport<cr>", desc = "Coverage: Report" },
		{ "<leader>cC", "<cmd>CoverageClear<cr>", desc = "Coverage: Clear" },
	},
}
