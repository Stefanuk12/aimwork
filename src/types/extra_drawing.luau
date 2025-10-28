export type DrawingBaseData = {
    Visible: boolean,
    ZIndex: number,
    Transparency: number,
    Color: Color3,
}
export type DrawingBaseOptionalData = {
    Visible: boolean?,
    ZIndex: number?,
    Transparency: number?,
    Color: Color3?,
}
export type DrawingBase = DrawingBaseData & {
    Remove: (self: DrawingBase) -> (),
}

export type DrawingLineData = DrawingBaseData & {
    Thickness: number,
    From: Vector2,
    To: Vector2,
}
export type DrawingLineOptionalData = DrawingBaseOptionalData & {
    Thickness: number?,
    From: Vector2?,
    To: Vector2?,
}
export type DrawingLine = DrawingBase & DrawingLineData

export type DrawingTextData = DrawingBaseData & {
    Text: string,
    Size: number,
    Center: boolean,
    Outline: boolean,
    OutlineColor: Color3,
    Position: Vector2,
    TextBounds: Vector2, --readonly
}
export type DrawingTextOptionalData = DrawingBaseOptionalData & {
    Text: string?,
    Size: number?,
    Center: boolean?,
    Outline: boolean?,
    OutlineColor: Color3?,
    Position: Vector2?,
}
export type DrawingText = DrawingBase & DrawingTextData

export type DrawingImageData = DrawingBaseData & {
    Data: string, --writeonly
    Size: Vector2,
    Position: Vector2,
    Rounding: number,   
}
export type DrawingImageOptionalData = DrawingBaseOptionalData & {
    Data: string?,
    Size: Vector2?,
    Position: Vector2?,
    Rounding: number?,
}
export type DrawingImage = DrawingBase & DrawingImageData

export type DrawingCircleData = DrawingBaseData & {
    Thickness: number,
    NumSides: number,
    Radius: number,
    Filled: boolean,
    Position: Vector2,
}
export type DrawingCircleOptionalData = DrawingBaseOptionalData & {
    Thickness: number?,
    NumSides: number?,
    Radius: number?,
    Filled: boolean?,
    Position: Vector2?,
}
export type DrawingCircle = DrawingBase & DrawingCircleData

export type DrawingSquareData = DrawingBaseData & {
    Thickness: number,
    Size: Vector2,
    Position: Vector2,
    Filled: boolean,
}
export type DrawingSquareOptionalData = DrawingBaseOptionalData & {
    Thickness: number?,
    Size: Vector2?,
    Position: Vector2?,
    Filled: boolean?,
}
export type DrawingSquare = DrawingBase & DrawingSquareData

export type DrawingQuadData = DrawingBaseData & {
    Thickness: number,
    PointA: Vector2,
    PointB: Vector2,
    PointC: Vector2,
    PointD: Vector2,
    Filled: boolean,
}
export type DrawingQuadOptionalData = DrawingBaseOptionalData & {
    Thickness: number?,
    PointA: Vector2?,
    PointB: Vector2?,
    PointC: Vector2?,
    PointD: Vector2?,
    Filled: boolean?,
}
export type DrawingQuad = DrawingBase & DrawingQuadData

export type DrawingTriangleData = DrawingBaseData & {
    Thickness: number,
    PointA: Vector2,
    PointB: Vector2,
    PointC: Vector2,
    Filled: boolean,
}
export type DrawingTriangleOptionalData = DrawingBaseOptionalData & {
    Thickness: number?,
    PointA: Vector2?,
    PointB: Vector2?,
    PointC: Vector2?,
    Filled: boolean?,
}
export type DrawingTriangle = DrawingBase & DrawingTriangleData

export type DrawingFonts = {
    UI: number,
    System: number,
    Plex: number,
    Monospace: number,
}
export type DrawingFontsData = {
    UI: number?,
    System: number?,
    Plex: number?,
    Monospace: number?,
}

export type DrawingEnum =
    { Kind: "Line", Value: DrawingLine } |
    { Kind: "Text", Value: DrawingText } |
    { Kind: "Image", Value: DrawingImage } |
    { Kind: "Circle", Value: DrawingCircle } |
    { Kind: "Square", Value: DrawingSquare } |
    { Kind: "Quad", Value: DrawingQuad } |
    { Kind: "Triangle", Value: DrawingTriangle }
export type DrawingDataEnum =
    { Kind: "Line", Value: DrawingLineData } |
    { Kind: "Text", Value: DrawingTextData } |
    { Kind: "Image", Value: DrawingImageData } |
    { Kind: "Circle", Value: DrawingCircleData } |
    { Kind: "Square", Value: DrawingSquareData } |
    { Kind: "Quad", Value: DrawingQuadData } |
    { Kind: "Triangle", Value: DrawingTriangleData }
export type DrawingOptionalDataEnum =
    { Kind: "Line", Value: DrawingLineOptionalData } |
    { Kind: "Text", Value: DrawingTextOptionalData } |
    { Kind: "Image", Value: DrawingImageOptionalData } |
    { Kind: "Circle", Value: DrawingCircleOptionalData } |
    { Kind: "Square", Value: DrawingSquareOptionalData } |
    { Kind: "Quad", Value: DrawingQuadOptionalData } |
    { Kind: "Triangle", Value: DrawingTriangleOptionalData }
export type DrawingEnumWithData =
    { Kind: "Line", Value: DrawingLine?, Data: DrawingLine } |
    { Kind: "Text", Value: DrawingText?, Data: DrawingText } |
    { Kind: "Image", Value: DrawingImage?, Data: DrawingImage } |
    { Kind: "Circle", Value: DrawingCircle?, Data: DrawingCircle } |
    { Kind: "Square", Value: DrawingSquare?, Data: DrawingSquare } |
    { Kind: "Quad", Value: DrawingQuad?, Data: DrawingQuad } |
    { Kind: "Triangle", Value: DrawingTriangle?, Data: DrawingTriangleData }


export type DrawingNewTypes = "Line" | "Text" | "Image" | "Circle" | "Square" | "Quad" | "Triangle"
export type DrawingObject = DrawingLine | DrawingText | DrawingImage | DrawingCircle | DrawingSquare | DrawingQuad | DrawingTriangle
export type DrawingObjectData = DrawingLineData | DrawingTextData | DrawingImageData | DrawingCircleData | DrawingSquareData | DrawingQuadData | DrawingTriangleData

export type DrawingNewFunction =
    (("Line") -> DrawingLine)
    & (("Text") -> DrawingText)
    & (("Image") -> DrawingImage)
    & (("Circle") -> DrawingCircle)
    & (("Square") -> DrawingSquare)
    & (("Quad") -> DrawingQuad)
    & (("Triangle") -> DrawingTriangle)
export type DrawingNewWithPropsFunction =
    (("Line", DrawingLineData?) -> DrawingLine)
    & (("Text", DrawingTextData?) -> DrawingText)
    & (("Image", DrawingImageData?) -> DrawingImage)
    & (("Circle", DrawingCircleData?) -> DrawingCircle)
    & (("Square", DrawingSquareData?) -> DrawingSquare)
    & (("Quad", DrawingQuadData?) -> DrawingQuad)
    & (("Triangle", DrawingTriangleData?) -> DrawingTriangle)
export type DrawingSetPropertiesFunction =
    ((DrawingLine, DrawingLineData) -> DrawingLine)
    & ((DrawingText, DrawingTextData) -> DrawingText)
    & ((DrawingImage, DrawingImageData) -> DrawingImage)
    & ((DrawingCircle, DrawingCircleData) -> DrawingCircle)
    & ((DrawingSquare, DrawingSquareData) -> DrawingSquare)
    & ((DrawingQuad, DrawingQuadData) -> DrawingQuad)   
    & ((DrawingTriangle, DrawingTriangleData) -> DrawingTriangle)

export type Drawing = {
    Fonts: DrawingFonts,
    new: DrawingNewFunction
}

return true
