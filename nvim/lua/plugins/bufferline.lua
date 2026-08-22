-- Visualize buffers as tabs - bufferline
return {
	{
		"akinsho/bufferline.nvim",
		version = "4.9.1",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
        config = function ()
            require("bufferline").setup{}
        end
	},
}
