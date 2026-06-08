(function () {
    const TABLE_SELECTOR = 'table[data-sortable-table]';
    const SORTABLE_SELECTOR = 'th[data-sortable-type]';
    const STYLE_ID = 'table-sort-styles';

    function injectStyles() {
        if (document.getElementById(STYLE_ID)) {
            return;
        }

        const style = document.createElement('style');
        style.id = STYLE_ID;
        style.textContent = `
            table[data-sortable-table] th[data-sortable-type] {
                cursor: pointer;
                user-select: none;
                position: relative;
                padding-right: 1.6rem;
                transition: background-color 0.15s ease;
            }

            table[data-sortable-table] th[data-sortable-type]:hover {
                background-color: rgba(148, 163, 184, 0.08);
            }

            table[data-sortable-table] th[data-sortable-type]::after {
                content: "⇅";
                position: absolute;
                right: 0.65rem;
                top: 50%;
                transform: translateY(-50%);
                font-size: 0.7rem;
                opacity: 0.35;
            }

            table[data-sortable-table] th[data-sortable-type][aria-sort="ascending"]::after {
                content: "▲";
                opacity: 1;
            }

            table[data-sortable-table] th[data-sortable-type][aria-sort="descending"]::after {
                content: "▼";
                opacity: 1;
            }
        `;
        document.head.appendChild(style);
    }

    function normalize(value) {
        return String(value == null ? '' : value).trim();
    }

    function parseValue(raw, type) {
        const value = normalize(raw);

        if (!value) {
            return null;
        }

        if (type === 'number') {
            const parsedNumber = Number(value.replace(/[^0-9.-]/g, ''));
            return Number.isNaN(parsedNumber) ? null : parsedNumber;
        }

        if (type === 'date') {
            const isoMatch = value.match(/^(\d{4})-(\d{2})-(\d{2})$/);
            if (isoMatch) {
                return Date.parse(`${isoMatch[1]}-${isoMatch[2]}-${isoMatch[3]}T00:00:00`);
            }

            const dmyMatch = value.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
            if (dmyMatch) {
                return Date.parse(`${dmyMatch[3]}-${dmyMatch[2]}-${dmyMatch[1]}T00:00:00`);
            }

            const parsedDate = Date.parse(value);
            return Number.isNaN(parsedDate) ? null : parsedDate;
        }

        return value.toLowerCase();
    }

    function compareValues(left, right, type) {
        const leftValue = parseValue(left, type);
        const rightValue = parseValue(right, type);

        if (leftValue == null && rightValue == null) {
            return 0;
        }
        if (leftValue == null) {
            return 1;
        }
        if (rightValue == null) {
            return -1;
        }

        if (type === 'number' || type === 'date') {
            return leftValue - rightValue;
        }

        return leftValue.localeCompare(rightValue, undefined, {
            numeric: true,
            sensitivity: 'base'
        });
    }

    function getCellValue(row, index) {
        const cell = row.children[index];
        if (!cell) {
            return '';
        }

        const sortValue = cell.getAttribute('data-sort-value');
        return sortValue != null && sortValue !== '' ? sortValue : (cell.textContent || '');
    }

    function setHeaderState(headers, activeHeader, direction) {
        headers.forEach((header) => {
            if (header === activeHeader) {
                header.setAttribute('aria-sort', direction);
            } else {
                header.setAttribute('aria-sort', 'none');
            }
        });
    }

    function sortTable(table, header, direction) {
        const tbody = table.tBodies[0];
        if (!tbody) {
            return;
        }

        const headers = Array.from(table.querySelectorAll(SORTABLE_SELECTOR));
        const headerIndex = headers.indexOf(header);
        if (headerIndex === -1) {
            return;
        }

        const sortType = header.dataset.sortableType || 'text';
        const rows = Array.from(tbody.rows);
        const multiplier = direction === 'descending' ? -1 : 1;

        rows.sort((rowA, rowB) => {
            const comparison = compareValues(
                getCellValue(rowA, headerIndex),
                getCellValue(rowB, headerIndex),
                sortType
            );

            if (comparison !== 0) {
                return comparison * multiplier;
            }

            return rowA.rowIndex - rowB.rowIndex;
        });

        rows.forEach((row) => tbody.appendChild(row));
        setHeaderState(headers, header, direction);
    }

    function setupTable(table) {
        const headers = Array.from(table.querySelectorAll(SORTABLE_SELECTOR));
        if (!headers.length) {
            return;
        }

        headers.forEach((header) => {
            header.setAttribute('role', 'button');
            header.setAttribute('tabindex', '0');
            header.setAttribute('aria-sort', 'none');

            header.addEventListener('click', () => {
                const currentDirection = header.getAttribute('aria-sort');
                const nextDirection = currentDirection === 'ascending' ? 'descending' : 'ascending';
                sortTable(table, header, nextDirection);
            });

            header.addEventListener('keydown', (event) => {
                if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault();
                    header.click();
                }
            });
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        injectStyles();
        document.querySelectorAll(TABLE_SELECTOR).forEach(setupTable);
    });
})();
