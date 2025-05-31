export interface IHandDetectedResult {
    hand?: string;
    landmarks?: Array<IHandLandmark[]>;
}

export interface IHandLandmark {
    z?: number;
    y?: number;
    x?: number;
    cameraWidth?: number;
    cameraHeight?: number;
    keypoint?: number;
}