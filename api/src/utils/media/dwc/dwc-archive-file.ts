import xlsx from 'xlsx';
import { CSVWorksheet, ICsvState } from '../csv/csv-file';
import { EMLFile } from '../eml/eml-file';
import { ArchiveFile, IMediaState, MediaValidation } from '../media-file';
import { ValidationSchemaParser } from '../validation/validation-schema-parser';

export enum DWC_CLASS {
  EVENT = 'event',
  OCCURRENCE = 'occurrence',
  MEASUREMENTORFACT = 'measurementorfact',
  RESOURCERELATIONSHIP = 'resourcerelationship',
  TAXON = 'taxon',
  LOCATION = 'location',
  RECORD = 'record',
  EML = 'eml'
}

export const DEFAULT_XLSX_SHEET = 'Sheet1';

export type DWCWorksheets = { [name in DWC_CLASS]?: CSVWorksheet };

/**
 * Supports Darwin Core Archive CSV files.
 *
 * Expects an array of known named-files
 *
 * @export
 * @class DWCArchive
 */
export class DWCArchive {
  rawFile: ArchiveFile;

  mediaValidation: MediaValidation;

  worksheets: DWCWorksheets;

  eml: EMLFile | undefined;

  constructor(archiveFile: ArchiveFile) {
    this.rawFile = archiveFile;

    this.mediaValidation = new MediaValidation(this.rawFile.fileName);

    this.worksheets = {};

    // parse archive files
    this._initArchiveFiles();
  }

  _initArchiveFiles() {
    // See https://www.npmjs.com/package/xlsx#parsing-options for details on parsing options
    const parsingOptions: xlsx.ParsingOptions = { raw: true };

    for (const rawFile of this.rawFile.mediaFiles) {
      switch (rawFile.name) {
        case DWC_CLASS.EVENT:
          this.worksheets[DWC_CLASS.EVENT] = new CSVWorksheet(
            rawFile.name,
            xlsx.read(rawFile.buffer, parsingOptions).Sheets[DEFAULT_XLSX_SHEET]
          );
          break;
        case DWC_CLASS.OCCURRENCE:
          this.worksheets[DWC_CLASS.OCCURRENCE] = new CSVWorksheet(
            rawFile.name,
            xlsx.read(rawFile.buffer, parsingOptions).Sheets[DEFAULT_XLSX_SHEET]
          );
          break;
        case DWC_CLASS.MEASUREMENTORFACT:
          this.worksheets[DWC_CLASS.MEASUREMENTORFACT] = new CSVWorksheet(
            rawFile.name,
            xlsx.read(rawFile.buffer, parsingOptions).Sheets[DEFAULT_XLSX_SHEET]
          );
          break;
        case DWC_CLASS.RESOURCERELATIONSHIP:
          this.worksheets[DWC_CLASS.RESOURCERELATIONSHIP] = new CSVWorksheet(
            rawFile.name,
            xlsx.read(rawFile.buffer, parsingOptions).Sheets[DEFAULT_XLSX_SHEET]
          );
          break;
        case DWC_CLASS.TAXON:
          this.worksheets[DWC_CLASS.TAXON] = new CSVWorksheet(
            rawFile.name,
            xlsx.read(rawFile.buffer, parsingOptions).Sheets[DEFAULT_XLSX_SHEET]
          );
          break;
        case DWC_CLASS.LOCATION:
          this.worksheets[DWC_CLASS.LOCATION] = new CSVWorksheet(
            rawFile.name,
            xlsx.read(rawFile.buffer, parsingOptions).Sheets[DEFAULT_XLSX_SHEET]
          );
          break;
        case DWC_CLASS.RECORD:
          this.worksheets[DWC_CLASS.RECORD] = new CSVWorksheet(
            rawFile.name,
            xlsx.read(rawFile.buffer, parsingOptions).Sheets[DEFAULT_XLSX_SHEET]
          );
          break;
        case DWC_CLASS.EML:
          this.eml = new EMLFile(rawFile);
          break;
      }
    }
  }

  /**
   * This function checks worksheet data if the DwCArchive only contains metadata
   *
   * @returns {boolean} True if no worksheet data is present
   */
  isMetaDataOnly(): boolean {
    return (
      this.eml !== undefined &&
      !this.worksheets.event &&
      !this.worksheets.occurrence &&
      !this.worksheets.measurementorfact &&
      !this.worksheets.resourcerelationship &&
      !this.worksheets.taxon &&
      !this.worksheets.location &&
      !this.worksheets.record
    );
  }

  isMediaValid(validationSchemaParser: ValidationSchemaParser): IMediaState {
    const validators = validationSchemaParser.getSubmissionValidations();

    const mediaValidation = this.validate(validators as DWCArchiveValidator[]);

    return mediaValidation.getState();
  }

  isContentValid(validationSchemaParser: ValidationSchemaParser): ICsvState[] {
    const csvStates: ICsvState[] = [];

    Object.keys(this.worksheets).forEach((fileName) => {
      const fileValidators = validationSchemaParser.getFileValidations(fileName);

      const columnValidators = validationSchemaParser.getAllColumnValidations(fileName);

      const validators = [...fileValidators, ...columnValidators];

      const worksheet: CSVWorksheet = this.worksheets[fileName];

      if (!worksheet) {
        return;
      }

      const csvValidation = worksheet.validate(validators);

      csvStates.push(csvValidation.getState());
    });

    return csvStates;
  }

  /**
   * Executes each validator function in the provided `validators` against this instance, returning
   * `this.mediaValidation`
   *
   * @param {DWCArchiveValidator[]} validators
   * @return {*}  {MediaValidation}
   * @memberof DWCArchive
   */
  validate(validators: DWCArchiveValidator[]): MediaValidation {
    validators.forEach((validator) => validator(this));

    return this.mediaValidation;
  }

  /**
   * Returns normalized DwC Archive file data
   *
   * @return {*}  {string}
   */
  normalize(): string {
    const normalized = {};

    Object.entries(this.worksheets).forEach(([key, value]) => {
      if (value) {
        normalized[key] = value.getRowObjects();
      }
    });

    return JSON.stringify(normalized);
  }
}

export type DWCArchiveValidator = (dwcArchive: DWCArchive) => DWCArchive;
