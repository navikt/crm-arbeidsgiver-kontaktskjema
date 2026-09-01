const ENHETER_ENDPOINT = 'https://data.brreg.no/enhetsregisteret/api/enheter';
const UNDERENHETER_ENDPOINT = 'https://data.brreg.no/enhetsregisteret/api/underenheter';

export class EregUnavailableError extends Error {} // network failure, timeout, 500
export class EregTechnicalError extends Error {} // 400, uventet status, parsefeil

// returns null       → no match found (search endpoint returns 200 with empty result, not 404)
// throws Unavailable → network failure, timeout, 500
// throws Technical   → 400, uventet status, parsefeil
export async function getEntityData(organizationNumber) {
    const subUnitResponse = await doCallout(`${UNDERENHETER_ENDPOINT}?organisasjonsnummer=${organizationNumber}`);
    if (subUnitResponse.status !== 200) {
        throwForStatus(subUnitResponse.status);
    }
    const subUnitMatch = firstMatch(await subUnitResponse.json(), 'underenheter');
    if (subUnitMatch) {
        return toSubUnit(subUnitMatch);
    }

    const unitResponse = await doCallout(`${ENHETER_ENDPOINT}?organisasjonsnummer=${organizationNumber}`);
    if (unitResponse.status !== 200) {
        throwForStatus(unitResponse.status);
    }
    const unitMatch = firstMatch(await unitResponse.json(), 'enheter');
    if (!unitMatch) {
        return null;
    }
    const entityData = toUnit(unitMatch);
    await addSubUnits(entityData);
    return entityData;
}

function firstMatch(json, embeddedKey) {
    return json?._embedded?.[embeddedKey]?.[0] ?? null;
}

async function addSubUnits(entityData) {
    try {
        const response = await doCallout(
            `${UNDERENHETER_ENDPOINT}?overordnetEnhet=${entityData.organizationNumber}&size=1000`
        );
        if (response.status !== 200) {
            throw new EregTechnicalError(`Unexpected status ${response.status}`);
        }
        const { page, _embedded } = await response.json();
        entityData.totalSubUnitsCount = page.totalElements;
        entityData.subUnits = (_embedded?.underenheter ?? []).map(toSubUnit);
    } catch (e) {
        // Non-critical feature: return an empty list instead of failing the whole lookup.
        entityData.totalSubUnitsCount = 0;
        entityData.subUnits = [];
    }
}

function toSubUnit(json) {
    return {
        name: json.navn,
        organizationNumber: json.organisasjonsnummer,
        isSubunit: true
    };
}

function toUnit(json) {
    return {
        name: json.navn,
        organizationNumber: json.organisasjonsnummer,
        isSubunit: false,
        totalSubUnitsCount: 0,
        subUnits: []
    };
}

function throwForStatus(status) {
    if (status === 500) {
        throw new EregUnavailableError(`Ereg service unavailable (status ${status})`);
    }
    throw new EregTechnicalError(`Unexpected status ${status}`);
}

async function doCallout(url) {
    try {
        return await fetch(url);
    } catch (e) {
        throw new EregUnavailableError(e.message);
    }
}
