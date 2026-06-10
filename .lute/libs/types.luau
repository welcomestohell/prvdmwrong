local fs = require "@std/fs"
local path = require "@std/path"
local syntax = require "@std/syntax"
local syntaxTypes = require "@std/syntax/types"

-- Rojo

export type RojoMappings = { [string]: { RojoMappingSegment } }

export type RojoMappingSegment = {
	name: string,
	className: string?,
}

export type RojoPath = string | { optional: string }

export type RojoNode = {
	["$className"]: string?,
	["$path"]: RojoPath?,
	[string]: RojoNode,
}

export type RojoProjectTarget = "source" | "output"

-- Rojo Sourcemap

export type SourcemapNode = {
	name: string,
	filePaths: { string }?,
	children: { SourcemapNode }?,
}

export type SourcemapIndices = { [string]: string }

-- Monorepo

export type Place = {
	title: string,
	subtitle: string?,
	folderName: string,
	placeId: string?,
	dependencies: { string }?,
}

export type PlaceMixin = {
	transpile: boolean,
	folderName: string,
	rojo: {
		{
			name: string,
			className: string?,
		}
	},
}

export type LuauConfig = {
	wth: {
		place: Place?,
		placeMixin: PlaceMixin?,
	},
}

export type MonorepoMember = {
	place: Place?,
	placeMixin: PlaceMixin?,

	folderName: string,
	dirName: string,
	dirPath: path.Pathlike,
	configPath: path.Pathlike,
	outputDirPath: path.Pathlike,

	rojoMappings: {
		[RojoProjectTarget]: { [keyof<RojoMappings>]: path.Pathlike? },
	},
}

export type Monorepo = { [any]: MonorepoMember }

export type RepositoryConfig = typeof(require "@scripts/libs/../../.config")

-- Build

export type BuildContext = {
	monorepo: Monorepo,
	repository: RepositoryConfig,

	member: MonorepoMember,
	memberPlace: Place,
	memberDependencies: { MonorepoMember },
	rojoMembers: { MonorepoMember },

	outputPath: path.Pathlike,
	outputProjectPath: path.Pathlike,
	sourcemapPath: path.Pathlike,
	sourcemapProjectPath: path.Pathlike,

	sourcemapIndices: SourcemapIndices,
	globals: { [string]: string | boolean | nil },
}

export type TransfomerContext = {
	tree: syntax.ParseResult,
	filepath: path.Pathlike,
	source: string,
	build: BuildContext,
}

export type Transformer = (ctx: TransfomerContext) -> syntaxTypes.Replacements

-- Lute

export type Watcher = typeof(fs.watch "")

return nil
